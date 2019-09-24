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

        set_value(e, measurement)

        e.measurements << m

        t = Time.current
      end
    end.save!
  end

  private

  def set_value(evaluation, measurement)
    v = measurement.value

    if (name = measurement.name.split('.').last) == 'service_description'
      evaluation.service_description = v.present?
      evaluation.language = measurement.activities&.last&.supported_languages&.ensure_utf8&.to_json
    elsif name == 'void'
      evaluation.void = v.present?
      evaluation.publisher = measurement.activities&.last&.publishers&.ensure_utf8&.to_json
      evaluation.license = measurement.activities&.last&.licenses&.ensure_utf8&.to_json
    elsif v.present?
      if name == 'data_entry'
        evaluation.send("#{name}=", v)
        evaluation.data_scale = Math.log10(v) if v.positive?
      elsif respond_to?("#{name}=")
        evaluation.send("#{name}=", v.is_a?(String) ? v.ensure_utf8 : v)
      end
    end
  rescue StandardError => e
    Rails.logger.error('Crawler') { ([e.message] + e.backtrace).join("\n") }
  end

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
      resource_uri: endpoint.resource_uris.map { |x| Umakadata::ResourceURI.new(x.attributes) }.presence,
      vocabulary_prefix: VocabularyPrefix.where.not(endpoint_id: @endpoint_id).pluck(:uri)
    }.compact
  end

  def logger_options
    {
      level: Rails.logger.level,
      formatter: Umakadata::Logger::Formatter.new
    }
  end

  def log_file_path
    Rails.root.join('log', log_file_name).to_s
  end

  def log_file_name
    "crawl_#{@crawl_id}_#{crawl.started_at.strftime('%Y%m%d_%H%M%S')}.log"
  end
end
