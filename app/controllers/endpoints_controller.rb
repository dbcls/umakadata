require 'sparql/client'
require 'rdf/turtle'

class EndpointsController < ApplicationController
  before_action :set_endpoint, only: [:show]

  def top
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).where(conditions).order('evaluations.score DESC')
  end

  def search
    @conditions = {:name => '', :score => ''}
    if request.post?
      @conditions = params
      conditions = {'evaluations.latest': true}
      @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
      add_like_condition('name', params['name']) if !params['name'].empty?
      add_gte_condition('evaluations.score', params['score']) if !params['score'].empty?
    else
      @endpoints = []
    end
  end

  def add_like_condition(column, value)
    @endpoints = @endpoints.where("#{column} LIKE ?", "%#{value}%")
  end

  def add_gte_condition(column, value)
    @endpoints = @endpoints.where("#{column} >= ?", "#{value}")
  end

  def show
  end

  def scores
    count = Hash.new(0)
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
    @endpoints.each do |endpoint|
      rank = endpoint.evaluation.first.rank
      count[rank] += 1
    end
    render :json => scores_json(count)
  end

  def alive
    count = Hash.new(0)
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
    @endpoints.each do |endpoint|
      alive = endpoint.evaluation.first.alive
      alive ? count[:alive] += 1 : count[:dead] += 1
    end
    render :json => alive_json(count)
  end

  def service_descriptions
    count = Hash.new(0)
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
    @endpoints.each do |endpoint|
      sd = endpoint.evaluation.first.service_description
      sd.present? ? count[:true] += 1 : count[:false] += 1
    end
    render :json => service_descriptions_json(count)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_endpoint
      conditions = {'evaluations.latest': true}
      @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
      @endpoint = @endpoints.find(params[:id])
      @evaluation = @endpoint.evaluation.first

      @void = @evaluation.void_ttl
      void = parseVoid(@void)
      if void.nil?
        @has_void = false
      else
        @has_void = true
        @license = []
        @publisher = []
        void.each do |graph, verb, object|
          @license.push object.to_s   if verb == RDF::URI('http://purl.org/dc/terms/license')
          @publisher.push object.to_s if verb == RDF::URI('http://purl.org/dc/terms/publisher')
        end
      end
      @license = @license.join('<br/>')
      @publisher = @publisher.join('<br/>')

      @linked_data_rule_score = 0
      @linked_data_rule_score += 25 if @evaluation.subject_is_uri
      @linked_data_rule_score += 25 if @evaluation.subject_is_http_uri
      @linked_data_rule_score += 25 if @evaluation.uri_provides_info
      @linked_data_rule_score += 25 if @evaluation.contains_links
      @linked_data_rule_score = @linked_data_rule_score.to_s + "%"
    end

    def parseVoid(str)
      begin
        graphs = RDF::Graph.new << RDF::Turtle::Reader.new(str)
        return graphs
      rescue => e
        puts e
      end
      return nil
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def endpoint_params
      params.require(:endpoint).permit(:name, :url)
    end

    def scores_json(count)
      [
        {
          value: count[1],
          color: "#1D2088",
          highlight: "#6356A3",
          label: "Rank A"
        },
        {
          value: count[2],
          color: "#00A0E9",
          highlight: "#00B9EF",
          label: "Rank B"
        },
        {
          value: count[3],
          color: "#009944",
          highlight: "#03EB37",
          label: "Rank C"
        },
        {
          value: count[4],
          color: "#FFF100",
          highlight: "#FFF462",
          label: "Rank D"
        },
        {
          value: count[5],
          color: "#E60012",
          highlight: "#FF5A5E",
          label: "Rank E"
        }
      ]
    end

    def alive_json(count)
      [
        {
          value: count[:alive],
          color: "#00A0E9",
          highlight: "#00B9EF",
          label: "Alive"
        },
        {
          value: count[:dead],
          color: "#E60012",
          highlight: "#FF5A5E",
          label: "Dead"
        }
      ]
    end

    def service_descriptions_json(count)
      [
        {
          value: count[:true],
          color: "#00A0E9",
          highlight: "#00B9EF",
          label: "Have"
        },
        {
          value: count[:false],
          color: "#E60012",
          highlight: "#FF5A5E",
          label: "Do not have"
        }
      ]
    end

end
