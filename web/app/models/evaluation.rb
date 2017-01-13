require 'rdf'
require 'rdf/rdfxml'
require 'rdf/turtle'
require 'rdf/ntriples'
require 'rdf/vocab'
require 'umakadata/linkset'
require 'umakadata/data_format'

class Evaluation < ActiveRecord::Base

  extend Umakadata::DataFormat

  belongs_to :endpoint
  belongs_to :crawl_log
  scope :created_at, ->(date) { where('created_at': date) }

  def self.lookup(endpoint_id, evaluation_id)
    if evaluation_id.nil?
      evaluation = Evaluation.where({endpoint_id: endpoint_id, latest: true}).first
    else
      evaluation = Evaluation.find(evaluation_id)
      return nil if evaluation.nil?
      return nil if evaluation[:endpoint_id].to_i != endpoint_id.to_i
    end
    return evaluation
  end

  def self.previous(endpoint_id, evaluation_id)
    self.where('id < ?', evaluation_id).where(endpoint_id: endpoint_id).order('id DESC').first
  end

  def self.next(endpoint_id, evaluation_id)
    self.where('id > ?', evaluation_id).where(endpoint_id: endpoint_id).order('id ASC').first
  end

  def self.record(endpoint, retriever, rdf_prefixes)
    self.transaction do
      self.where(endpoint_id: endpoint.id).update_all("latest = false")
      self.retrieve_and_record endpoint, retriever, rdf_prefixes
    end
    rescue => e
    puts e.message
    puts e.backtrace
  end

  def self.retrieve_and_record(endpoint, retriever, rdf_prefixes)
    eval = Evaluation.new
    eval.endpoint_id = endpoint.id
    eval.retrieved_at = retriever.retrieved_at

    eval.latest = true

    logger = Umakadata::Logging::Log.new
    eval.alive = retriever.alive?(logger: logger)
    eval.alive_log = logger.as_json

    if eval.alive
      eval.support_graph_clause = retriever.support_graph_clause
      self.retrieve_service_description(retriever, eval)
      self.retrieve_void(retriever, eval)
      self.retrieve_linked_data_rules(retriever, eval)

      logger = Umakadata::Logging::Log.new
      eval.execution_time = retriever.execution_time(logger: logger)
      eval.execution_time_log = logger.as_json

      logger = Umakadata::Logging::Log.new
      eval.cool_uri_rate = retriever.cool_uri_rate(logger: logger)
      eval.cool_uri_rate_log = logger.as_json

      logger = Umakadata::Logging::Log.new
      eval.support_turtle_format = retriever.check_content_negotiation(Umakadata::DataFormat::TURTLE, logger: logger)
      eval.support_turtle_format_log = logger.as_json
      logger = Umakadata::Logging::Log.new
      eval.support_xml_format    = retriever.check_content_negotiation(Umakadata::DataFormat::RDFXML, logger: logger)
      eval.support_content_negotiation_log = logger.as_json
      logger = Umakadata::Logging::Log.new
      eval.support_html_format   = retriever.check_content_negotiation(Umakadata::DataFormat::HTML, logger: logger)
      eval.support_html_format_log = logger.as_json

      eval.support_content_negotiation = eval.support_turtle_format ||
                                         eval.support_xml_format ||
                                         eval.support_html_format

      logger = Umakadata::Logging::Log.new
      metadata = retriever.metadata(logger: logger)
      eval.metadata_score = retriever.score_metadata(metadata, logger: logger)
      eval.metadata_log = logger.as_json

      unless metadata.empty?
        list_of_ontologies_log = Umakadata::Logging::Log.new
        list_of_ontologies = retriever.list_ontologies(metadata, logger: list_of_ontologies_log)

        score_ontologies_for_endpoints_log = Umakadata::Logging::Log.new
        score_ontologies_for_endpoints_log.push list_of_ontologies_log
        logger = Umakadata::Logging::Log.new
        logger.push score_ontologies_for_endpoints_log

        score = retriever.score_ontologies_for_endpoints(list_of_ontologies, rdf_prefixes, logger: score_ontologies_for_endpoints_log)
        logger.result = "Ontology score is #{score}"
        eval.ontology_score = score
        eval.ontology_log = logger.as_json
        RdfPrefix.delete_all(endpoint_id: endpoint.id)
        list_of_ontologies.each do |ontology|
          rdf_prefix = RdfPrefix.new(endpoint_id: endpoint.id, uri: ontology)
          rdf_prefix.save
        end

        list_of_ontologies_in_LOV_log = Umakadata::Logging::Log.new
        list_of_ontologies_in_LOV = retriever.list_ontologies_in_LOV(metadata, logger: list_of_ontologies_in_LOV_log)

        score_ontologies_for_LOV_log = Umakadata::Logging::Log.new
        score_ontologies_for_LOV_log.push list_of_ontologies_in_LOV_log
        logger.push score_ontologies_for_LOV_log

        score_LOV = retriever.score_ontologies_for_LOV(list_of_ontologies, list_of_ontologies_in_LOV, logger: score_ontologies_for_LOV_log)

        score += score_LOV

        logger.result = "Ontology score is #{score}"
        eval.ontology_score = score
        eval.ontology_log = logger.as_json
      end

      logger = Umakadata::Logging::Log.new
      eval.number_of_statements = retriever.number_of_statements(logger: logger)
      eval.number_of_statements_log = logger.as_json

      logger = Umakadata::Logging::Log.new
      self.check_update(retriever, eval, logger: logger)
      eval.last_updated_log = logger.as_json

    end

    eval.alive_rate = Evaluation.calc_alive_rate(eval)
    eval.score = Evaluation.calc_score(eval)
    eval.rank  = Evaluation.calc_rank(eval.score)
    eval.update_interval = Evaluation.calc_update_interval(eval)

    return eval if eval.save!
  end

  def self.retrieve_service_description(retriever, eval)
    logger = Umakadata::Logging::Log.new
    service_description = retriever.service_description(logger: logger)
    eval.service_description_log = logger.as_json
    return if service_description.nil?
    eval.response_header     = service_description.response_header
    eval.service_description = service_description.text
    eval.supported_language = retriever.supported_language(service_description)
  end

  def self.retrieve_void(retriever, eval)
    logger = Umakadata::Logging::Log.new
    eval.void_uri = retriever.well_known_uri
    void = retriever.void_on_well_known_uri(logger: logger)
    if !void.nil? && !void.text.nil?
      eval.void_ttl = void.text
      eval.license = void.license.to_json unless void.license.nil?
      eval.publisher = void.publisher.to_json unless void.publisher.nil?
    else
      void_in_sd = self.extract_void_from_service_description(eval.service_description)
      if void_in_sd == ''
        logger.result << ', and VoID is not found in Service Description'
      else
        logger.result << ', so VoID is extracted from Service Description'
      end
      eval.void_ttl = void_in_sd
    end
    eval.void_ttl_log = logger.as_json
    eval.linksets = retriever.linksets(eval.void_ttl)
  end

  def self.retrieve_linked_data_rules(retriever, eval)
    eval.subject_is_uri = true
    logger = Umakadata::Logging::Log.new
    eval.subject_is_http_uri = retriever.http_subject?(logger: logger)
    eval.subject_is_http_uri_log = logger.as_json
    if eval.endpoint.prefixes.present?
      prefixes = Prefix.where(endpoint_id: eval.endpoint_id).pluck(:uri)
      logger = Umakadata::Logging::Log.new
      eval.uri_provides_info = retriever.uri_provides_info?(prefixes, logger: logger)
      eval.uri_provides_info_log = logger.as_json
      logger = Umakadata::Logging::Log.new
      eval.contains_links = retriever.contains_links?(prefixes, logger: logger)
      eval.contains_links_log = logger.as_json
    end
  end

  def self.calc_alive_rate(eval)
    today = Time.zone.now
    first = 29.days.ago(Time.zone.local(today.year, today.month, today.day, 0, 0, 0))
    last = 1.days.ago(Time.zone.local(today.year, today.month, today.day, 23, 59, 59))
    count = self.where(endpoint_id: eval.endpoint_id, retrieved_at: first..last).group(:alive).count
    count[true] ||= 0
    count[false] ||= 0
    total = count[true] + count[false] + 1.0
    alive = count[true] + (eval.alive? ? 1 : 0)
    percentage = (alive / total) * 100
    return percentage.round(1)
  end

  def self.calc_score(eval)
    rates = self.calc_rates(eval)
    return rates.inject(0.0) { |r, i| r += i } / rates.count
  end

  def self.calc_rank(score)
    case score
    when (0..20)   then 1
    when (20..40)  then 2
    when (40..60)  then 3
    when (60..80)  then 4
    when (80..100) then 5
    else 1
    end
  end

  def self.calc_update_interval(eval)
    intervals = self.where(endpoint_id: eval.endpoint_id).group(:last_updated).pluck(:last_updated)
    return nil if intervals.empty?

    last_updated = eval.last_updated
    intervals.push(last_updated) unless intervals.include?(last_updated)
    intervals.delete(nil) if intervals.include?(nil)
    return nil unless intervals.size >= 2

    intervals.sort!
    sum = 0
    for i in 0..intervals.size - 2
      diff = intervals[i + 1] - intervals[i]
      sum += diff.to_i
    end
    sum.to_f / (intervals.size - 1)
  end

  def self.rates(id, evaluation_id)
    conditions = {'evaluations.endpoint_id': id}
    conditions['evaluations.latest'] = true if evaluation_id.nil?
    conditions['evaluations.id'] = evaluation_id unless evaluation_id.nil?
    endpoint = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions).first
    evaluation = endpoint.evaluation
    return self.calc_rates(evaluation)
  end

  def self.avg_rates
    total = [0, 0, 0, 0, 0, 0]
    count = 0
    conditions = {'evaluations.latest': true}
    endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions).all
    endpoints.each do |endpoint|
      evaluation = endpoint.evaluation
      rates = self.calc_rates(evaluation)
      for i in 0..5 do
        total[i] += rates[i]
      end
      count += 1
    end
    avg = [0, 0, 0, 0, 0, 0]
    for i in 0..5 do
      avg[i] = total[i] / count
    end
    return avg
  end

  def self.calc_rates(eval)
    rates = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0]

    # availability
    rates[0] += eval.alive_rate unless eval.alive_rate.blank?

    #freshness
    rates[1] = 50.0

    #operation
    rates[2] += 50.0 unless eval.service_description.blank?
    rates[2] += 50.0 unless eval.void_ttl.blank?

    #usefulness
    rates[3] += 50.0 * eval.ontology_score / 100.0 unless eval.ontology_score.blank?
    rates[3] += 50.0 * eval.metadata_score / 100.0 unless eval.metadata_score.blank?

    #validity
    rates[4] += 40.0 * eval.cool_uri_rate.to_f / 100.0 unless eval.cool_uri_rate.blank?
    rates[4] += 20.0 if eval.subject_is_http_uri
    rates[4] += 20.0 if eval.uri_provides_info
    rates[4] += 20.0 if eval.contains_links

    #performance
    if eval.execution_time.present? && eval.number_of_statements.present? && eval.number_of_statements > 0
      second = (eval.execution_time / eval.number_of_statements) * 1000000
      rates[5] = 100.0 * (1.0 - second)
    end
    rates[5] = 0.0 if rates[5] < 0.0 || 100.0 < rates[5]

    return rates.map{ |v| v.to_i }
  end

  def self.check_update(retriever, eval, logger: nil)
    last_updated = retriever.last_updated(eval.service_description, eval.void_ttl, logger: logger)
    if !last_updated.nil?
      eval.last_updated = last_updated[:date].strftime('%F')
      eval.last_updated_source = last_updated[:source]
      logger.result = "The endpoint seems to be updated on #{eval.last_updated}"
      return
    end

    log = Umakadata::Logging::Log.new
    logger.push log unless logger.nil?
    latest = retriever.first_last(eval.number_of_statements, logger: log)
    prevStatus = UpdateStatus.where(:endpoint_id => eval.endpoint_id).order('created_at DESC').first
    latestStatus = UpdateStatus.record(eval.endpoint_id, latest)
    previous = self.where(:endpoint_id => eval.endpoint_id).order('created_at DESC').first
    if UpdateStatus.different?(prevStatus, latestStatus, logger: log) || previous.nil?
      eval.last_updated = Time.now.strftime('%F')
      eval.last_updated_source = 'Adhoc'
      log.result = 'The latest update status is different from previous one'
      logger.result = "The endpoint seems to be updated on #{eval.last_updated}"
      return
    end

    eval.last_updated = previous[:last_updated]
    eval.last_updated_source = previous[:last_updated_source]
    log.result = 'The latest update status and previous one are the same'
    logger.result = "The endpoint seems to be updated on #{eval.last_updated}"
  end

  def self.extract_void_from_service_description(service_description)
    sd = triples(service_description)
    return '' if sd.nil?
    format = if ttl?(service_description)
               :ttl
             elsif xml?(service_description)
               :rdfxml
             else
               :ntriples
             end
    statements = []
    sd.each do |subject, predicate, object|
      if predicate =~ %r|void| || predicate =~ %r|isPartOf|
        statements << RDF::Statement.new(subject, predicate, object)
      end
    end
    return '' if statements.empty?
    buffer = StringIO.new
    prefixes = {:dcterms => RDF::Vocab::DC, :void => RDF::Vocab::VOID}
    RDF::Writer.for(format).new(buffer, :prefixes => prefixes) do |writer|
      statements.each do | statement |
        writer << statement
      end
    end
    buffer.close
    buffer.string
  end

end
