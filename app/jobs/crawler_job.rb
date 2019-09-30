require 'umakadata'
require 'forwardable'

class CrawlerJob
  include Sidekiq::Worker
  extend Forwardable

  sidekiq_options queue: :crawler, retry: 0, backtrace: true

  def perform(crawl_id, endpoint_id)
    @crawl_id = crawl_id
    @endpoint_id = endpoint_id

    evaluation = create_evaluation.tap { |x| x.update!(crawler.basic_information) }

    begin
      start_time = Time.current
      crawler.run do |measurement|
        set_value(evaluation, measurement, start_time)
      end

      evaluation.save!

      endpoint.update_vocabulary_prefixes!(*crawler.vocabulary_prefix)
    rescue StandardError => e
      raise e
    ensure
      crawl.finalize! if crawl.last?
    end
  end

  private

  def create_evaluation
    Evaluation.create! do |e|
      e.created_at = Time.current
      e.crawl = crawl
      e.endpoint = endpoint
    end
  end

  def set_value(evaluation, measurement, start_time = Time.current)
    hash = measurement.to_h
    hash[:activities] = hash[:activities]&.map { |activity| Activity.new(activity.to_h) }

    evaluation.measurements << begin
      Measurement.new(hash) do |x|
        x.started_at = start_time
        x.finished_at = Time.current
      end
    end

    v = measurement.value

    if (name = measurement.name.split('.').last) == 'service_description'
      evaluation.service_description = v.present?
      evaluation.language = measurement.activities&.last&.supported_languages&.ensure_utf8&.to_json
    elsif name == 'void'
      evaluation.void = v.present?
      evaluation.publisher = measurement.activities&.last&.publishers&.ensure_utf8&.to_json
      evaluation.license = measurement.activities&.last&.licenses&.ensure_utf8&.to_json
    elsif name == 'data_entry'
      evaluation.data_entry = v
      evaluation.data_scale = Math.log10(v) if v.present? && v.positive?
    elsif evaluation.respond_to?("#{name}=")
      evaluation.send("#{name}=", v.is_a?(String) ? v.ensure_utf8 : v)
    else
      error('Crawler') { "Missing method #{name}= for #{evaluation.class}" }
    end
  rescue StandardError => e
    error('Crawler') { ([e.message] + e.backtrace).join("\n") }
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
      vocabulary_prefix_others: vocabulary_prefix
    }.compact
  end

  def vocabulary_prefix
    if (cache = VocabularyPrefix.caches).present?
      logger.info('VocabularyPrefix') { 'Cached prefixes will be used.' }
      cache.reject { |x| x['endpoint_id'] == @endpoint_id }.map { |x| x['uri'] }.uniq
    else
      logger.info('VocabularyPrefix') { 'Prefixes from database will be used.' }
      VocabularyPrefix.where.not(endpoint_id: @endpoint_id).pluck(:uri).uniq
    end
  end

  def logger_options
    {
      level: ::Logger::INFO,
      formatter: Umakadata::Logger::Formatter.new
    }
  end

  def log_file_path
    Rails.root.join('log', log_file_name).to_s
  end

  def log_file_name
    "crawl_#{@crawl_id}_#{crawl.started_at.strftime('%Y%m%d_%H%M%S')}.log"
  end

  def logger
    @logger ||= Umakadata::Crawler.config.logger
  end

  def_delegators :logger, :debug, :info, :warn, :error, :fatal
end
