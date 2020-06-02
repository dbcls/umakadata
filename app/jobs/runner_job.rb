class RunnerJob
  include Sidekiq::Worker

  sidekiq_options queue: :runner

  # Start runner job asynchronously
  #
  # @param [Array<Integer>] id an array of endpoint id
  def perform(*id)
    check_crawls

    return unless scheduled_time? && crawl_not_performed?
    return if Crawl.processing.present?
    return if Crawl.skipped.on(Date.current).present?

    Crawl.start!(*id)
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
