class Evaluation < ApplicationRecord
  belongs_to :crawl
  belongs_to :endpoint
  has_many :measurements, dependent: :destroy

  attribute :publisher, :json_array
  attribute :license, :json_array
  attribute :language, :json_array
  attribute :links_to_other_datasets, :json_array

  before_save :update_score

  scope :alive, -> { where(alive: true) }
  scope :has_service_description, -> { where(service_description: true) }

  class << self
    def rank_number(label)
      case label.upcase
      when 'A'
        5
      when 'B'
        4
      when 'C'
        3
      when 'D'
        2
      when 'E'
        1
      else
        nil
      end
    end
  end

  def update_score
    self.alive_rate = calc_alive_rate
    self.alive_score = calc_alive_score
    self.score = (vs = scores.values).sum / vs.size.to_f
    self.rank = calc_rank

    self
  end

  def previous
    Evaluation
      .eager_load(:crawl)
      .where(endpoint_id: endpoint_id)
      .where('crawls.started_at < ?', crawl.started_at)
      .last
  end

  def next
    Evaluation
      .eager_load(:crawl)
      .where(endpoint_id: endpoint_id)
      .where('crawls.started_at > ?', crawl.started_at)
      .first
  end

  def calc_alive_rate
    date = crawl.started_at
    duration = 29.days.ago(date).beginning_of_day..1.day.ago(date).end_of_day

    past_eval = self.class
                  .where(crawl_id: Crawl.where(started_at: duration).pluck(:id))
                  .where(endpoint_id: endpoint_id)

    count = past_eval.count + 1
    alive = past_eval.where(alive: true).count + (self.alive ? 1 : 0)

    alive / count.to_f
  end

  def calc_alive_score
    f = -> (x) { (10.0 / 3.0) * Math.sqrt(-1.0 + (6.0 * Math.sqrt(100.0 - x ** 2 / 100.0)) + (9.0 * x ** 2 / 100.0)) }

    previous_score = previous&.alive_score || ((alive_rate || 0) * 100.0)

    if alive
      [f.(previous_score), 100.0].min
    else
      [previous_score - (10.0 / 3.0), 0.0].max
    end
  end

  def days_since_last_update
    return unless last_updated

    (crawl.started_at.to_date - last_updated.to_date).to_i
  rescue
    nil
  end

  module Scores
    def availability
      alive_score || (alive_rate || 0) * 100.0
    end

    def freshness
      case (n = days_since_last_update)
      when 0..30
        100.0
      when 31..365
        100.0 - 70.0 * (n - 30) / 335
      else
        30.0
      end
    end

    def operation
      v = 0.0
      v += 50.0 if service_description.present?
      v += 50.0 if void.present?
      v
    end

    def usefulness
      v = 0.0
      v += ontology
      v += metadata
      v / 2.0
    end

    def validity
      v = 0.0
      v += 40.0 * cool_uri / 100.0 if cool_uri.present?
      v += 20.0 if http_uri
      v += 20.0 if provide_useful_information
      v += 20.0 if link_to_other_uri
      v
    end

    def performance
      return 0.0 unless execution_time.present? && data_entry.presence&.positive?

      t = execution_time / data_entry.to_f
      v = 100.0 * (1.0 - t * 1_000_000) # negative if t >= 1 micro sec.

      [[0.0, v].max, 100.0].min
    end
  end
  include Scores

  def scores
    {
      availability: availability,
      freshness: freshness,
      operation: operation,
      usefulness: usefulness,
      validity: validity,
      performance: performance
    }
  end

  def calc_rank
    case score
    when (20..40) then
      2
    when (40..60) then
      3
    when (60..80) then
      4
    when (80..100) then
      5
    else
      1
    end
  end

  def rank_label
    case rank
    when 5
      'A'
    when 4
      'B'
    when 3
      'C'
    when 2
      'D'
    else
      'E'
    end
  end
end
