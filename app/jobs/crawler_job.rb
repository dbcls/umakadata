require 'umakadata'

class CrawlerJob
  include Sidekiq::Worker

  sidekiq_options queue: :crawler, retry: 1, backtrace: true

  def perform(crawl_id, endpoint_id)
    @crawl_id = crawl_id
    @endpoint_id = endpoint_id

    Evaluation.new(created_at: Time.current, crawl: crawl, endpoint: endpoint) do |e|
      t = Time.current

      crawler.run do |measurement|
        hash = measurement.to_h
        hash[:activities] = hash[:activities]&.map { |activity| Activity.new(activity.to_h) }

        m = Measurement.new(hash) do |x|
          x.started_at = t
          x.finished_at = Time.current
        end

        e.measurements << m

        t = Time.current
      end
    end.save!
  end

  private

  # @return [Crawl]
  def crawl
    Crawl.find(@crawl_id)
  end

  def endpoint
    Endpoint.find(@endpoint_id)
  end

  def crawler
    Umakadata::Crawler.new(endpoint.endpoint_url, **crawler_options)
  end

  def crawler_options
    {
      logger: {
        logdev: "log/#{crawl.started_at.strftime('%Y%m%d_%H%M%S')}_crawl_#{@crawl_id}.log",
        level: ::Logger::INFO
      },
      exclude_graph: endpoint.excluding_graphs.map(&:uri).presence,
      resource_uri: endpoint.resource_uris.map { |x| Umakadata::ResourceURI.new(x.attributes) }.presence
    }.compact
  end
end
