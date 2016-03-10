require 'sparql/client'
require 'rdf/turtle'
require 'yummydata/data_format'

class EndpointsController < ApplicationController

  include Yummydata::DataFormat

  before_action :set_endpoint, only: [:show]

  def top
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).where(conditions).order('evaluations.score DESC')
  end

  def search
  end

  def show
  end

  def scores
    count = Hash.new(0)
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).where(conditions).order('evaluations.score DESC')
    @endpoints.each do |endpoint|
      rank = endpoint.evaluation.rank
      count[rank] += 1
    end
    render :json => scores_json(count)
  end

  def rader
    data = {
      data: Evaluation.rates(params[:id]),
      avg: Evaluation.avg_rates
    }
    respond_to do |format|
      format.any { render :json => data }
      format.json { render :json => data }
    end
  end

  def alive
    count = Hash.new(0)
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
    @endpoints.each do |endpoint|
      alive = endpoint.evaluation.alive
      alive ? count[:alive] += 1 : count[:dead] += 1
    end
    render :json => alive_json(count)
  end

  def service_descriptions
    count = Hash.new(0)
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
    @endpoints.each do |endpoint|
      sd = endpoint.evaluation.service_description
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
      @evaluation = @endpoint.evaluation

      @void = @evaluation.void_ttl
      void = triples(@void)
      @license = []
      @publisher = []
      if void.nil?
        @void = ''
      else
        void.each do |graph, verb, object|
          @license.push object.to_s   if verb == RDF::URI('http://purl.org/dc/terms/license')
          @publisher.push object.to_s if verb == RDF::URI('http://purl.org/dc/terms/publisher')
        end
      end
      @license = @license.join('<br/>')
      @publisher = @publisher.join('<br/>')
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def endpoint_params
      params.require(:endpoint).permit(:name, :url)
    end

    def scores_json(count)
      [
        {
          value: count[5],
          color: "#1D2088",
          highlight: "#6356A3",
          label: "Rank A"
        },
        {
          value: count[4],
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
          value: count[2],
          color: "#FFF100",
          highlight: "#FFF462",
          label: "Rank D"
        },
        {
          value: count[1],
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
