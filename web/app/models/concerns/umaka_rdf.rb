require 'rdf'

module UmakaRDF
  @@base_uri = 'http://d.umaka.dbcls.jp'.freeze
  @@prefixes = {
    'rdf': 'http://www.w3.org/1999/02/22-rdf-syntax-ns#',
    'uvo': 'http://d.umaka.dbcls.jp/vocaburaries#',
    'uen': 'http://d.umaka.dbcls.jp/endpoints/',
    'uev': 'http://d.umaka.dbcls.jp/evaluations/',
  }
  @@endpoint_properties = [
    'name',
    'url'
  ].freeze
  @@evaluation_properties = [
    'alive',
    'alive_rate',
#    'response_header',
#    'service_description',
    'void_uri',
#    'void_ttl',
    'subject_is_uri',
    'subject_is_http_uri',
    'uri_provides_info',
    'contains_links',
    'score',
    'rank',
    'cool_uri_rate',
    'support_content_negotiation',
    'support_turtle_format',
    'support_xml_format',
    'support_html_format',
    'execution_time',
    'metadata_score',
    'ontology_score',
    'vocabulary_score',
    'last_updated',
    'last_updated_source',
    'update_interval',
    'number_of_statements',
    'created_at'
  ].freeze

  def self.build(data)
    graph = RDF::Graph.new
    data.each do |endpoint|
      add_endpoint(graph, endpoint)
    end
    graph
  end

  def self.prefixes
    @@prefixes
  end

  def self.add_endpoint(graph, endpoint)
    uri = RDF::URI(@@base_uri)
    endpoint_id = @@base_uri + '/endpoints/' + endpoint['id'].to_s

    evaluation = endpoint['evaluation']
    evaluation_id = @@base_uri + '/evaluations/' + evaluation['id'].to_s

    graph << make_statement(endpoint_id, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", RDF::URI.new(@@base_uri + '/vocaburaries#Endpoint'))
    endpoint.each do |key, value|
      graph << make_statement(endpoint_id, @@base_uri + '/endpoints/' + key, value) if @@endpoint_properties.include?(key)
    end

    graph << make_statement(endpoint_id, @@base_uri + '/vocaburaries#has', RDF::URI.new(evaluation_id))

    graph << make_statement(evaluation_id, "http://www.w3.org/1999/02/22-rdf-syntax-ns#type", RDF::URI.new(@@base_uri + '/vocaburaries#Evaluation'))
    evaluation.each do |key, value|
      graph << make_statement(evaluation_id, @@base_uri + '/evaluations/' + key, value) if @@evaluation_properties.include?(key)
    end
  end

  def self.make_statement(s, v, o)
    RDF::Statement.new(RDF::URI.new(s), RDF::URI.new(v), o.nil? ? "" : o)
  end

  private_class_method(:add_endpoint)
  private_class_method(:make_statement)
end
