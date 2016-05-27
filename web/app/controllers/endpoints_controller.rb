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

  def log
    evaluation = Evaluation.where(:id => params[:evaluation_id]).first
    @endpoint_id = evaluation.endpoint_id
    json = nil
    case(params[:name])
    when 'alive' then
      json = evaluation.alive_error_reason
    when 'execution_time' then
      json = evaluation.execution_time_error_reason
    when 'service_description'
      json = evaluation.service_description_error_reason
    when 'void_ttl' then
      json = evaluation.void_ttl_error_reason
    when 'subject_is_uri'
      json = evaluation.subject_is_uri_error_reason
    when 'subject_is_http_uri'
      json = evaluation.subject_is_http_uri_error_reason
    when 'uri_provides_info'
      json = evaluation.uri_provides_info_error_reason
    when 'contains_links'
      json = evaluation.contains_links_error_reason
    when 'metadata_score' then
      json = evaluation.metadata_error_reason
    when 'ontology_score' then
      json = evaluation.ontology_log
    when 'vocabulary_score' then
      json = evaluation.vocabulary_log
    when 'support_xml_format' then
      json = evaluation.support_content_negotiation_error_reason
    when 'support_html_format' then
      json = evaluation.support_html_format_log
    when 'support_turtle_format' then
      json = evaluation.support_turtle_format_log
    when 'cool_uri_rate' then
      json = evaluation.cool_uri_rate_log
    else
      json = nil
    end

    begin
      @log = JSON.parse(json)
    rescue
      @log = json
    end

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
    labels = Array.new
    availability = Array.new
    freshness = Array.new
    operation = Array.new
    usefulness = Array.new
    validity = Array.new
    performance = Array.new
    rank = Array.new

    target_evaluation = Evaluation.lookup(params[:id], params[:evaluation_id])
    to =  1.days.ago(target_evaluation.created_at.to_datetime())
    from = 28.days.ago(to)
    (from..to).each {|date|
      labels.push(date.strftime('%m/%d'))
      day_begin = DateTime.new(date.year, date.mon, date.day, 0, 0, 0, date.offset)
      day_end = DateTime.new(date.year, date.mon, date.day, 23, 59, 59, date.offset)
      evaluation = Evaluation.where(created_at: day_begin..day_end, endpoint_id: params[:id]).first || Evaluation.new
      rates = Evaluation.calc_rates(evaluation)
      availability.push(rates[0])
      freshness.push(rates[1])
      operation.push(rates[2])
      usefulness.push(rates[3])
      validity.push(rates[4])
      performance.push(rates[5])
      rank.push(evaluation.score.presence || 0)
    }

    labels.push(target_evaluation.created_at.strftime('%m/%d'))
    rates = Evaluation.calc_rates(target_evaluation)
    availability.push(rates[0])
    freshness.push(rates[1])
    operation.push(rates[2])
    usefulness.push(rates[3])
    validity.push(rates[4])
    performance.push(rates[5])
    rank.push(target_evaluation.score.presence || 0)

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
    today = DateTime.now
    from = 9.days.ago(today)

    labels = Array.new
    averages = Array.new
    medians = Array.new

    (from..today).each {|date|
      day_begin = DateTime.new(date.year, date.mon, date.day, 0, 0, 0, date.offset)
      day_end = DateTime.new(date.year, date.mon, date.day, 23, 59, 59, date.offset)
      scores = Evaluation.where(created_at: day_begin..day_end).pluck(:score).sort

      labels.push date.strftime('%m/%d')
      if scores.empty?
        averages.push 0
        medians.push 0
        next
      end

      averages.push scores.reduce(0, :+) / scores.length
      medians.push scores.length % 2 == 0 ? scores[scores.length / 2 - 1, 2].reduce(0, :+) / 2.0 : scores[scores.length / 2]
    }

    render :json => {
      :labels => labels,
      :datasets => [
        {
          :label => 'Average',
          :data => averages
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
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def endpoint_params
      params.require(:endpoint).permit(:name, :url)
    end

end
