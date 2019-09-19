class Evaluation < ApplicationRecord
  belongs_to :crawl
  belongs_to :endpoint
  has_many :measurements, dependent: :destroy

  before_save :update_score

  scope :alive, -> { where(alive: true) }

  def update_score
    return unless measurements.any? { |x| x.new_record? || x.changed? }

    self.alive_rate = calc_alive_rate
    self.score = (vs = scores.values).sum / vs.size.to_f
    self.rank = calc_rank
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

  def days_since_last_update
    return unless last_updated

    (crawl.started_at.to_date - last_updated.to_date).to_i
  rescue
    nil
  end

  module Scores
    def availability
      alive_rate * 100.0
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
      v += 50.0 if ontology.present?
      v += 50.0 if metadata.present?
      v
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

  # @param [Umakadata::Measurement] measurement
  def set_value(measurement)
    v = measurement.value

    if (name = measurement.name.split('.').last) == 'service_description'
      self.service_description = v.present?
      self.language = measurement.activities&.last&.supported_languages&.ensure_utf8&.to_json
    elsif name == 'void'
      self.void = v.present?
      self.publisher = measurement.activities&.last&.publishers&.ensure_utf8&.to_json
      self.license = measurement.activities&.last&.licenses&.ensure_utf8&.to_json
    elsif v.present?
      if name == 'data_entry'
        send("#{name}=", v)
        self.data_scale = Math.log10(v) if v.positive?
      elsif respond_to?("#{name}=")
        send("#{name}=", v.is_a?(String) ? v.ensure_utf8 : v)
      end
    end
  end
end
