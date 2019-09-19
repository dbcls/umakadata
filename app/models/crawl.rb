class Crawl < ApplicationRecord
  has_many :evaluations, dependent: :destroy

  scope :finished, -> { where.not(finished_at: nil) }
  scope :latest, -> { finished.order(started_at: :desc).first }
  scope :oldest, -> { finished.order(started_at: :asc).first }
  scope :on, -> x { where(started_at: x.all_day).first }

  include CrawlerTask

  class << self
    def data_collection
      finished.count
    end

    def days_without_data
      ((Time.current - latest.finished_at) / 1.day).to_i if latest.present?
    end
  end

  def number_of_endpoints
    evaluations.count
  end

  def number_of_active_endpoints
    evaluations.alive.count
  end

  def alive_rate
    return 0 unless (v = number_of_endpoints).positive?
    number_of_active_endpoints / v.to_f
  end

  def data_entries
    evaluations.map(&:data_entry).compact.sum
  end
end
