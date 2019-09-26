class RunnerJob
  include Sidekiq::Worker

  sidekiq_options queue: :runner

  def perform
    check_crawls

    return unless scheduled_time? && crawl_not_performed?

    Umakadata::Crawler.config.logger = Rails.logger
    Umakadata::LinkedOpenVocabulary.update
    VocabularyPrefix.caches = VocabularyPrefix.all.map(&:attributes)

    Crawl.start!
  end

  private

  def check_crawls
    return unless Crawl.processing.present?

    Crawl.processing.each { |c| c.finalize! if c.finished? }
  end

  def scheduled_time?
    Crawl.start_time(Date.current) <= Time.current
  end

  def crawl_not_performed?
    Crawl.on(Date.current).blank?
  end
end
