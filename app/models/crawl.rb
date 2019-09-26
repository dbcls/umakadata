class Crawl < ApplicationRecord
  has_many :evaluations, dependent: :destroy

  scope :finished, -> { where.not(finished_at: nil) }

  include CrawlerTask

  class << self
    def latest
      finished.order(started_at: :desc).first
    end

    def oldest
      finished.order(started_at: :asc).first
    end

    def on(date)
      return nil unless date.respond_to?(:all_day)

      where(started_at: date.all_day).first
    end

    def data_collection
      finished.count
    end

    def days_without_data
      ((Time.current - latest.finished_at) / 1.day).to_i if latest.present?
    end
  end

  def finalize!
    VocabularyPrefix.caches = nil
    update!(finished_at: Time.current)
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

  def number_of_service_descriptions
    evaluations.has_service_description.count
  end

  def service_descriptions_rate
    return 0 unless (v = number_of_endpoints).positive?

    evaluations.has_service_description.count / v.to_f
  end

  def data_entries
    evaluations.map(&:data_entry).compact.sum
  end

  def score_average
    evaluations.average(:score)
  end

  def score_median
    (evaluations.maximum(:score) + evaluations.minimum(:score)) / 2.0
  end
end
