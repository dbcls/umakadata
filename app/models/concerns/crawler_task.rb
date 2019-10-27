module CrawlerTask
  extend ActiveSupport::Concern

  class CrawlDuplicateError < StandardError
  end

  module ClassMethods
    START_OFFSET = [0, 0, 18, 18, 12, 12, 6, 6].freeze

    # @param [Date, Time, DateTime, ActiveSupport::TimeWithZone] date
    # @return [ActiveSupport::TimeWithZone]
    def start_time(date)
      (date = utc_time(date))
        .change(hour: START_OFFSET[date.strftime('%j').to_i % 8])
        .in_time_zone(Time.zone)
    end

    # @param [Date, Time, DateTime, ActiveSupport::TimeWithZone] date
    # @return [Symbol] :asc or :desc
    def queue_order(date)
      (utc_time(date).strftime('%j').to_i % 2).zero? ? :asc : :desc
    end

    # Start crawler job asynchronously
    #
    # @param [Array<Integer>] id an array of endpoint id
    def start!(*id)
      if Crawl.find_by(started_at: Date.current.all_day)
        raise CrawlDuplicateError, "Crawl for #{Date.current} is already exist, "\
        'Stop and remove it before start new crawl.'
      end

      Umakadata::Crawler.config.logger = Rails.logger
      Umakadata::LinkedOpenVocabulary.update

      VocabularyPrefix.caches = VocabularyPrefix.all.map(&:attributes)

      crawl = create!(started_at: Time.current)
      endpoints = Endpoint.active.order(id: queue_order(Date.current))
      endpoints = endpoints.where(id: id) if id.present?

      endpoints.each do |endpoint|
        CrawlerJob.perform_async(crawl.id, endpoint.id)
      end
    end

    private

    def utc_time(obj)
      obj.is_a?(Date) ? Time.utc(obj.year, obj.month, obj.day) : obj.utc
    end
  end

  def queue
    Sidekiq::Queue
      .new('crawler')
      .select { |job| job.args.first == id }
      .map(&:args)
  end

  def retry_set
    Sidekiq::RetrySet
      .new
      .select { |job| job.queue == 'crawler' && job.args.first == id }
      .map(&:args)
  end

  # @return [Array<Array<Integer>] an array of [crawl_id, endpoint_id]
  def processing
    begin
      Sidekiq::Workers
        .new
        .select { |_, _, job| job.dig('queue') == 'crawler' && JSON.parse(job.dig('payload')).fetch('args', []).first == id }
        .map { |_, _, job| JSON.parse(job.dig('payload')).fetch('args', []) }
    rescue JSON::ParserError
      []
    end
  end

  def queued_endpoints
    Endpoint.active.where(id: (queue | retry_set | processing).map(&:last))
  end

  def finished_endpoints
    Endpoint.active.where(id: evaluations.pluck(:endpoint_id))
  end

  def last?
    job_size == 1
  end

  def finished?
    job_size.zero?
  end

  def processing?
    !finished?
  end

  private

  def job_size
    queue.size + retry_set.size + processing.size
  end
end
