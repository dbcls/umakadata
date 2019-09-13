require 'umakadata'

class CrawlerJob
  include Sidekiq::Worker

  sidekiq_options queue: :crawler, retry: 0, backtrace: true

  def perform(crawl_id, endpoint_id)
    @crawl_id = crawl_id
    @endpoint_id = endpoint_id

    Evaluation.new(attributes.merge(crawler.basic_information)) do |e|
      t = Time.current

      crawler.run do |measurement|
        hash = measurement.to_h
        hash[:activities] = hash[:activities]&.map { |activity| Activity.new(activity.to_h) }

        m = Measurement.new(hash) do |x|
          x.started_at = t
          x.finished_at = Time.current
        end

        e.set_value(measurement)

        e.measurements << m

        t = Time.current
      end
    end.save!
  end

  private

  # @return [Crawl]
  def crawl
    @crawl ||= Crawl.find(@crawl_id)
  end

  def endpoint
    @endpoint ||= Endpoint.find(@endpoint_id)
  end

  def attributes
    {
      created_at: Time.current,
      crawl: crawl,
      endpoint: endpoint
    }
  end

  def crawler
    @crawler ||= begin
      Umakadata::Crawler.config.backtrace = true
      Umakadata::Crawler.config.logger = ::Logger.new(log_file_path, **logger_options)
      Umakadata::Crawler.new(endpoint.endpoint_url, **crawler_options)
    end
  end

  def crawler_options
    {
      exclude_graph: endpoint.excluding_graphs.map(&:uri).presence,
      resource_uri: endpoint.resource_uris.map { |x| Umakadata::ResourceURI.new(x.attributes) }.presence
    }.compact
  end

  def logger_options
    {
      level: Logger::INFO,
      formatter: Umakadata::Logger::Formatter.new
    }
  end

  def log_file_path
    Rails.root.join('log', log_file_name).to_s
  end

  def log_file_name
    "#{crawl.started_at.strftime('%Y%m%d_%H%M%S')}_crawl_#{@crawl_id}.log"
  end
end
