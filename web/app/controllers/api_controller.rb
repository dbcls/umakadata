require 'json'

class ApiController < ApplicationController

  def specifications
  end

  def endpoints_search
    @conditions = params
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
    self.add_like_condition_for_name_url(params['name']) if !params['name'].blank?
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

  def endpoints_graph
    nodes = Endpoint.all.map do |endpoint|
      {
        :group => "nodes",
        :data => {
          :id => endpoint.id,
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

end
