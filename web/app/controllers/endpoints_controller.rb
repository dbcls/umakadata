require 'json'
require 'sparql/client'
require 'rdf/turtle'
require 'umakadata/data_format'
require 'umakadata/linkset'

class EndpointsController < ApplicationController

  include Umakadata::DataFormat
  include Umakadata::Linkset

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
    count = {1 => 0, 2 => 0, 3 => 0, 4 => 0, 5 => 0}
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).where(conditions).order('evaluations.score DESC')
    @endpoints.each do |endpoint|
      rank = endpoint.evaluation.rank
      count[rank] += 1
    end
    render :json => count
  end

  def radar
    data = {
      data: Evaluation.rates(params[:id], params[:evaluation_id]),
      avg: Evaluation.avg_rates
    }
    respond_to do |format|
      format.any { render :json => data }
      format.json { render :json => data }
    end
  end

  def score_history
    evaluations = Evaluation.where(:endpoint_id => params[:id]).limit(30).order('evaluations.created_at ASC')
    labels = []
    availability = []
    freshness = []
    operation = []
    usefulness = []
    validity = []
    performance = []
    rank = []
    evaluations.each do |evaluation|
      labels.push(evaluation.created_at.strftime('%m/%d'))
      rates = Evaluation.calc_rates(evaluation)
      availability.push(rates[0])
      freshness.push(rates[1])
      operation.push(rates[2])
      usefulness.push(rates[3])
      validity.push(rates[4])
      performance.push(rates[5])
      rank.push(evaluation.score)
    end

    render :json => {
      :labels => labels,
      :datasets => [
        {
          label: 'Availability',
          data: availability
        },
        {
          label: 'Freshness',
          data: freshness
        },
        {
          label: 'Operation',
          data: operation
        },
        {
          label: 'Usefulness',
          data: usefulness
        },
        {
          label: 'Validity',
          data: validity
        },
        {
          label: 'Performance',
          data: performance
        },
        {
          label: 'Rank',
          data: rank
        }
      ]
    }
  end

  def alive
    count = { :alive => 0, :dead => 0 }
    conditions = {'evaluations.latest': true}
    @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
    @endpoints.each do |endpoint|
      alive = endpoint.evaluation.alive
      alive ? count[:alive] += 1 : count[:dead] += 1
    end
    render :json => count
  end

  def service_descriptions
    count = { :true => 0, :false => 0 }
    conditions = {'evaluations.latest': true, 'evaluations.alive': true}
    @endpoints = Endpoint.includes(:evaluation).order('evaluations.score DESC').where(conditions)
    @endpoints.each do |endpoint|
      sd = endpoint.evaluation.service_description
      sd.present? ? count[:true] += 1 : count[:false] += 1
    end
    render :json => count
  end


  def score_statistics
    today = Time.zone.now
    from = 9.days.ago(Time.zone.local(today.year, today.month, today.day, 0, 0, 0))
    grouped_evaluations = Evaluation.where(created_at: from..today).group('date(created_at)').order('date(created_at)')
    labels = grouped_evaluations.count.keys.map{|date| date.strftime('%m/%d')}
    evaluations = Evaluation.where(created_at: from..today).all
    score_hash = {}
    scores = []
    evaluations.each do |evaluation|
      date = evaluation.created_at.strftime('%m/%d')
      if score_hash[date].nil?
        scores = []
        score_hash[date] = scores
      else
        scores = score_hash[date]
      end
      scores.push(evaluation.score)
    end
    medians = score_hash.map{|k, v|
      scores = v.sort
      scores.size % 2 == 0 ? scores[scores.size / 2 - 1, 2].inject(:+) / 2.0 : scores[scores.size / 2]
    }

    render :json => {
      :labels => labels,
      :datasets => [
        {
          :label => 'Average',
          :data => grouped_evaluations.average(:score).map{|k, v| v.to_i}
        },
        {
          :label => 'Median',
          :data => medians
        }
      ]
    }

  end

  def alive_statistics
    today = Time.zone.now
    from = 9.days.ago(Time.zone.local(today.year, today.month, today.day, 0, 0, 0))
    grouped_evaluations = Evaluation.where(created_at: from..today).group('date(created_at)').order('date(created_at)')
    labels = grouped_evaluations.count.keys.map{|date| date.strftime('%m/%d')}
    alive_data = grouped_evaluations.where(alive: true).count.values

    render :json => {
      :labels => labels,
      :datasets => [
        {
          label: 'Avlie',
          data: alive_data
        }
      ]
    }
  end

  def service_description_statistics
    today = Time.zone.now
    from = 9.days.ago(Time.zone.local(today.year, today.month, today.day, 0, 0, 0))
    grouped_evaluations = Evaluation.where(created_at: from..today).group('date(created_at)').order('date(created_at)')
    labels = grouped_evaluations.count.keys.map{|date| date.strftime('%m/%d')}
    have_data = grouped_evaluations.where.not(service_description: nil).count.values

    render :json => {
      :labels => labels,
      :datasets => [
        {
          label: 'Have',
          data: have_data
        }
      ]
    }
  end

  private
    def render_404
      render :file=>"/public/404.html", :status=>'404 Not Found'
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_endpoint
      @endpoint = Endpoint.find(params[:id])
      @evaluation = Evaluation.lookup(params[:id], params[:evaluation_id])
      if @evaluation.nil?
         render_404
         return
      end
      @prev_evaluation = Evaluation.previous(@endpoint[:id], @evaluation[:id])
      @next_evaluation = Evaluation.next(@endpoint[:id], @evaluation[:id])

      @cors = false
      if !@evaluation.response_header.blank?
        @evaluation.response_header.split(/\n/).each do |line|
          items = line.split(/\s*:\s*/)
          if items[0].downcase == 'access-control-allow-origin'
            @cors = true if items[1] == '*'
            break
          end
        end
      end

      @void = @evaluation.void_ttl
      void = triples(@void)
      @linksets = self.linksets(void)

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

      error = nil
      if !@evaluation.metadata_error_reason.nil?
        metadata_error_reason = JSON.parse(@evaluation.metadata_error_reason, {:symbolize_names => true})
        error = metadata_error_reason[:error]
      end

      if error.nil?
        @metadata_error_reason = nil
        return
      elsif error === 'graph'
        @metadata_error_reason = {
          type: 'Failed to retrieve graph',
          elements: [metadata_error_reason[:reason]]
        }
      elsif error === 'elements'
        reasons = metadata_error_reason[:reason]
        classes    = reasons[:classes]
        labels     = reasons[:labels]
        datatypes  = reasons[:datatypes]
        properties = reasons[:properties]
        @metadata_error_reason = {
          type: 'Errors occurs in the following RDF schema',
          elements: [
            "rdfs:Class: #{classes.size}",
            "rdfs:label: #{labels.size}",
            "rdfs:Datatype: #{datatypes.size}",
            "rdf:Property: #{properties.size}"
          ]
        }
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def endpoint_params
      params.require(:endpoint).permit(:name, :url)
    end

end
