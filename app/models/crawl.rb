class Crawl < ApplicationRecord
  has_many :evaluations, dependent: :destroy

  scope :finished, -> { where.not(finished_at: nil) }
  scope :processing, -> { where(finished_at: nil, skip: nil).or(Crawl.where(finished_at: nil, skip: false)) }
  scope :skipped, -> { where(finished_at: nil, skip: true) }

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
    update!(finished_at: Time.current)
    AdminUser.crawl_post_hook(self)

    return unless (email = ENV['UMAKADATA_MAILER_CRAWL_MAILER_TO'])

    CrawlerMailer.notify_finished_to(AdminUser.new(email: email), self).deliver_now
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

  def scores_average
    e = evaluations
    {
      availability: (xs = e.map(&:availability)).present? ? xs.sum / xs.size : 0.0,
      freshness: (xs = e.map(&:freshness)).present? ? xs.sum / xs.size : 0.0,
      operation: (xs = e.map(&:operation)).present? ? xs.sum / xs.size : 0.0,
      usefulness: (xs = e.map(&:usefulness)).present? ? xs.sum / xs.size : 0.0,
      validity: (xs = e.map(&:validity)).present? ? xs.sum / xs.size : 0.0,
      performance: (xs = e.map(&:performance)).present? ? xs.sum / xs.size : 0.0
    }
  end
end
