require 'json'

class ApiController < ApplicationController

  def specifications
  end

  def endpoints_search
    @conditions = params
    @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC')
    @endpoints = @endpoints.includes(:prefixes) unless params['prefix'].nil?
    self.add_like_condition_for_name_url(params['name']) if !params['name'].blank?
    self.add_like_condition_for_prefix(params['prefix']) if !params['prefix'].blank?
    self.add_date_condition(params['date']) if !params['date'].blank?
    self.add_range_condition('evaluations.score', params['score_lower'], params['score_upper'])
    self.add_range_condition('evaluations.alive_rate', params['alive_rate_lower'], params['alive_rate_upper'])
    self.add_rank_condition('evaluations.rank', params['rank']) if !params['rank'].blank?
    self.add_range_condition('evaluations.cool_uri_rate', params['cool_uri_rate_lower'], params['cool_uri_rate_upper'])
    self.add_range_condition('evaluations.ontology', params['ontology_lower'], params['ontology_upper'])
    self.add_range_condition('evaluations.metadata_score', params['metadata_lower'], params['metadata_upper'])
    self.add_range_condition('evaluations.vocabulary', params['vocabulary_lower'], params['vocabulary_upper'])
    self.add_is_not_empty_condition('evaluations.service_description') if !params['service_description'].blank?
    self.add_is_not_empty_condition('evaluations.void_ttl') if !params['void'].blank?
    self.add_is_not_empty_condition('evaluations.support_content_negotiation') if !params['content_negotiation'].blank?
    self.add_is_not_empty_condition('evaluations.support_html_format') if !params['html'].blank?
    self.add_is_not_empty_condition('evaluations.support_turtle_format') if !params['turtle'].blank?
    self.add_is_not_empty_condition('evaluations.support_xml_format') if !params['xml'].blank?
    self.add_equal_condition_for_prefix_filter(params['element_type'], params['prefix_filter_uri'], params['prefix_filter_uri_fragment']) if !params['element_type'].blank? && !params['prefix_filter_uri'].blank?

    respond_to do |format|
      format.jsonld  { render json: @endpoints.to_jsonld }
      format.xml     { render xml:  @endpoints.to_xml }
      format.rdfxml  { render xml:  @endpoints.to_rdfxml }
      format.ttl     { render text: @endpoints.to_ttl }
      format.json    { render json: @endpoints.to_pretty_json }
      format.any     { render json: @endpoints.to_pretty_json }
    end
  end

  def add_like_condition_for_name_url(value)
    @endpoints = @endpoints.where("LOWER(name) LIKE ? OR LOWER(url) LIKE ?", "%#{value.downcase}%", "%#{value.downcase}%")
  end

  def add_like_condition_for_prefix(value)
    @endpoints = @endpoints.where("LOWER(prefixes.uri) LIKE ?", "%#{value.downcase}%")
  end

  def add_is_not_empty_condition(column)
    @endpoints = @endpoints.where("#{column} IS NOT NULL AND #{column} <> ''")
  end

  def add_equal_condition(column, value)
    @endpoints = @endpoints.where(column => value)
  end

  def add_rank_condition(column, value)
    rank_values = { 'A' => 5, 'B' => 4, 'C' => 3, 'D' => 2, 'E' => 1 }
    add_equal_condition(column, rank_values[value]) unless rank_values[value].nil?
  end

  def add_date_condition(value)
    begin
      date = Time.parse(value)
      @endpoints = @endpoints.crawled_at(date)
    rescue
    end
  end

  def add_range_condition(column, lower, upper)
    if lower.blank? && upper.blank?
      return
    elsif lower.blank?
      @endpoints = @endpoints.where("#{column} <= ?", "#{upper}")
    elsif upper.blank?
      @endpoints = @endpoints.where("#{column} >= ?", "#{lower}")
    else
      @endpoints = @endpoints.where(column => Range.new(lower, upper))
    end
  end

  def add_equal_condition_for_prefix_filter(element_type, uri, fragment)
    identifier = "##{fragment}" unless fragment.blank?
    input_uri = "#{uri}#{identifier}"
    prefix_filters = PrefixFilter.where(element_type: element_type)
    endpoint_ids = prefix_filters.select{|prefix_filter| input_uri =~ /.*#{prefix_filter.uri}.*/}.map(&:endpoint_id)
    self.add_equal_condition(:id, endpoint_ids)
    self.filter_endpoints_with_sparql_query(element_type, input_uri)
  end

  def filter_endpoints_with_sparql_query(element_type, uri)
    query = create_filter_endpoints_query(element_type, uri)
    endpoint_ids = Array.new
    @endpoints.each do |endpoint|
      [:post, :get].each do |method|
        response = Umakadata::SparqlHelper.query(URI(endpoint.url), query, logger: nil, options: {method: method})
        if !response.nil? && response.length > 0
          endpoint_ids.push endpoint.id
          break
        end
      end
    end
    self.add_equal_condition(:id, endpoint_ids)
  end

  def create_filter_endpoints_query(element_type, uri)
    case element_type
    when 'subject'
      subject = "<#{uri}>"
      object = "?o"
    when 'object'
      subject = '?s'
      object = "<#{uri}>"
    end
    query = <<-SPARQL
SELECT
  *
WHERE
  {
    #{subject} ?p #{object}
  }
LIMIT 1
SPARQL

  end

  def endpoints_graph
    nodes = Endpoint.all.map do |endpoint|
      {
        :group => "nodes",
        :data => {
          :id => "n#{endpoint.id}",
          :name => endpoint.name
        }
      }
    end
    edges = Relation.all.map do |relation|
      next if !Endpoint.exists?(:id => relation.endpoint_id) || !Endpoint.exists?(:id => relation.dst_id)
      {
        :group => "edges",
        :data => {
          :id => "e#{relation.id}",
          :source => "n#{relation.endpoint_id}",
          :target => "n#{relation.dst_id}",
          :label => relation.name
        }
      }
    end
    edges.delete(nil)
    render :json => nodes.concat(edges)
  end

  def endpoint_id
    evaluation_id = ""
    unless params['date'].nil?
      begin
        date = Time.parse(params['date'])
        day_begin = Time.zone.local(date.year, date.month, date.day, 0, 0, 0)
        day_end = Time.zone.local(date.year, date.mon, date.day, 23, 59, 59)
        evaluations = Evaluation.where(:endpoint_id => params[:id]).created_at(day_begin..day_end)
        evaluation_id = evaluations.take.id
      rescue
      end
    end
    render :json => {:evaluation_id => evaluation_id}
  end

end
