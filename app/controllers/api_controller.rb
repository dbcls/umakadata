class ApiController < ApplicationController

  def endpoints_search
    @conditions = params
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
    self.add_like_condition('name', params['name']) if !params['name'].blank?
    self.add_range_condition('evaluations.score', params['score_lower'], params['score_upper'])
    self.add_range_condition('evaluations.alive_rate', params['alive_rate_lower'], params['alive_rate_upper'])
    self.add_equal_condition('evaluations.rank', params['rank']) if !params['rank'].blank?
    self.add_range_condition('evaluations.cool_uri_rate', params['cool_uri_rate_lower'], params['cool_uri_rate_upper'])
    self.add_range_condition('evaluations.ontology', params['ontology_lower'], params['ontology_upper'])
    self.add_range_condition('evaluations.metadata_coverage', params['metadata_lower'], params['metadata_upper'])
    self.add_range_condition('evaluations.vocabulary', params['vocabulary_lower'], params['vocabulary_upper'])
    self.add_is_not_empty_condition('evaluations.service_description') if !params['service_description'].blank?
    self.add_is_not_empty_condition('evaluations.void_ttl') if !params['void'].blank?
    self.add_is_not_empty_condition('evaluations.support_content_negotiation') if !params['content_negotiation'].blank?
    self.add_is_not_empty_condition('evaluations.support_html_format') if !params['html'].blank?
    self.add_is_not_empty_condition('evaluations.support_turtle_format') if !params['turtle'].blank?
    self.add_is_not_empty_condition('evaluations.support_xml_format') if !params['xml'].blank?
    render :json => @endpoints.to_json(:include => [:evaluation])
  end

  def add_like_condition(column, value)
    @endpoints = @endpoints.where("#{column} LIKE ?", "%#{value}%")
  end

  def add_is_not_empty_condition(column)
    @endpoints = @endpoints.where("#{column} IS NOT NULL AND #{column} <> ''")
  end

  def add_equal_condition(column, value)
    @endpoints = @endpoints.where(column => value)
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

end
