class ApiController < ApplicationController

  def endpoints_search
    @conditions = params
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
    self.add_like_condition('name', params['name']) if !params['name'].blank?
    self.add_gte_condition('evaluations.score', params['score']) if !params['score'].blank?
    render :json => @endpoints
  end

  def add_like_condition(column, value)
    @endpoints = @endpoints.where("#{column} LIKE ?", "%#{value}%")
  end

  def add_gte_condition(column, value)
    @endpoints = @endpoints.where("#{column} >= ?", "#{value}")
  end

end
