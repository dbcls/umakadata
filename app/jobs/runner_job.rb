class RunnerJob
  include Sidekiq::Worker

  sidekiq_options queue: :runner

  def perform
    return unless scheduled_time? && crawl_not_performed?

    Umakadata::Crawler.config.logger = Rails.logger
    Umakadata::LinkedOpenVocabulary.update

    Crawl.start!
  end

  private

  def scheduled_time?
    Crawl.start_time(Date.current) <= Time.current
  end

  def crawl_not_performed?
    Crawl.find_by(started_at: Date.current.all_day).blank?
  end
end
