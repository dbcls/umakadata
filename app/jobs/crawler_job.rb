require 'umakadata'
require 'forwardable'
require 'fileutils'

class CrawlerJob
  include Sidekiq::Worker
  extend Forwardable

  sidekiq_options queue: :crawler, retry: 0, backtrace: true

  def perform(crawl_id, endpoint_id)
    @crawl_id = crawl_id
    @endpoint_id = endpoint_id

    timeout = endpoint.timeout
    s1 = Time.current

    evaluation = create_evaluation

    begin
      evaluation.started_at = (s2 = Time.current)

      basic_information = crawler.basic_information || {}
      evaluation.update!({
                           service_keyword: basic_information[:service_keyword] || false,
                           graph_keyword: basic_information[:graph_keyword] || false,
                           cors: basic_information[:cors] || false
                         })

      crawler.run do |measurement|
        set_value(evaluation, measurement, s2) if measurement
        s2 = Time.current

        if timeout && (Time.current - s1) > timeout.hour
          evaluation.timeout = true
          break
        end
      end

      evaluation.save!

      endpoint.update_vocabulary_prefixes!(*crawler.vocabulary_prefix)

      evaluation.update!(finished_at: Time.current)

      remove_old_log_file
    rescue StandardError => e
      logger.error("ep = #{@endpoint_id}") { Array(e.backtrace).unshift(e.message).join("\n") }
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
      evaluation.void ||= measurement.activities&.last&.void_descriptions&.statements.present?
    elsif name == 'void'
      evaluation.void ||= v.present?
      evaluation.publisher = measurement.activities&.last&.publishers&.ensure_utf8&.to_json
      evaluation.license = measurement.activities&.last&.licenses&.ensure_utf8&.to_json
    elsif name == 'data_entry'
      evaluation.data_entry = v if v.present?
      evaluation.data_scale = Math.log10(v) if v.present? && v.positive?
    elsif name == 'links_to_other_datasets'
      evaluation.links_to_other_datasets = v.split("\n") if v.present?
    elsif evaluation.respond_to?("#{name}=")
      evaluation.send("#{name}=", v.is_a?(String) ? v.ensure_utf8 : v) if v.present?
    else
      logger.warn("ep = #{@endpoint_id}") { "Missing method #{name}= for #{evaluation.class}" }
    end
  rescue StandardError => e
    logger.error("ep = #{@endpoint_id}") { Array(e.backtrace).unshift(e.message).join("\n") }
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
      graphs: (g = endpoint.graph).present? ? { g.mode.to_sym => g.graph_list } : nil,
      resource_uri: endpoint.resource_uris.map { |x| Umakadata::ResourceURI.new(x.attributes) }.presence,
      vocabulary_prefix_others: vocabulary_prefix
    }.compact
  end

  def vocabulary_prefix
    if (cache = VocabularyPrefix.caches).present?
      logger.info("ep = #{@endpoint_id}") { 'Cached prefixes will be used.' }
      cache.reject { |x| x['endpoint_id'] == @endpoint_id }.map { |x| x['uri'] }.uniq
    else
      logger.info("ep = #{@endpoint_id}") { 'Prefixes from database will be used.' }
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

  def remove_old_log_file
    one_year_ago = Date.current.beginning_of_month.ago(1.year)

    Dir.glob(Rails.root.join('log', 'crawl_*.log')).each do |f|
      if (m = f.match(/crawl_.+_(\d+)_.+.log/)) && (date = m[1]) && Date.parse(date) < one_year_ago
        FileUtils.rm f
      end
    end
  end
end
