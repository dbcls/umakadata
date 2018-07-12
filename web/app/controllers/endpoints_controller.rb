require 'json'
require 'sparql/client'
require 'rdf/turtle'
require 'umakadata/data_format'

class EndpointsController < ApplicationController

  include Umakadata::DataFormat

  before_action :set_endpoint, only: [:info]
  before_action :set_start_date, only: [:index, :top, :show]

  def index
    @date = date_param
    crawl_log = CrawlLog.started_at(@date)
    if crawl_log.blank?
      @evaluations = Array.new
    else
      evaluations = crawl_log.evaluations.joins(:endpoint).order(endpointlist_param).pluck(:id, :score, :'endpoints.id', :'endpoints.name', :'endpoints.url')
      @evaluations = evaluations.map do |result|
        {
          :id   => result[0],
          :score => result[1],
          :endpoint => {
            :id   => result[2],
            :name => result[3],
            :url  => result[4]
          }
        }
      end
    end
  end

  def top
    @date = date_param
    @metrics = set_metrics
    crawl_log = CrawlLog.started_at(@date)
    if crawl_log.blank?
      @evaluations = Array.new
    else
      evaluations = crawl_log.evaluations.joins(:endpoint).order("score DESC").limit(5).pluck(:id, :score, :'endpoints.id', :'endpoints.name', :'endpoints.url')
      @evaluations = evaluations.map do |result|
        {
          :id   => result[0],
          :score => result[1],
          :endpoint => {
            :id   => result[2],
            :name => result[3],
            :url  => result[4]
          }
        }
      end
    end

  end

  def search
    @date = date_param
    evaluation = Evaluation.first
    return nil if evaluation.nil?
    @start_date = evaluation.retrieved_at.strftime('%d-%m-%Y')
  end

  def show
    @endpoint_id = params[:id]
    @evaluation_id = params[:evaluation_id]
  end

  def info
    @date = date_param
    count = PrefixFilter.where(endpoint_id: @endpoint[:id]).count()
    @uri_indexed = count > 0
    render layout: false
  end

  def log
    evaluation = Evaluation.where(:id => params[:evaluation_id]).first
    @endpoint_id = evaluation.endpoint_id
    json = nil
    case(params[:name])
      when 'alive' then
        json = evaluation.alive_log
      when 'last_updated' then
        json = evaluation.last_updated_log
      when 'execution_time' then
        json = evaluation.execution_time_log
      when 'service_description'
        json = evaluation.service_description_log
      when 'void_ttl' then
        json = evaluation.void_ttl_log
      when 'subject_is_http_uri'
        json = evaluation.subject_is_http_uri_log
      when 'uri_provides_info'
        json = evaluation.uri_provides_info_log
      when 'contains_links'
        json = evaluation.contains_links_log
      when 'metadata_score' then
        json = evaluation.metadata_log
      when 'ontology_score' then
        json = evaluation.ontology_log
      when 'support_xml_format' then
        json = evaluation.support_content_negotiation_log
      when 'support_html_format' then
        json = evaluation.support_html_format_log
      when 'support_turtle_format' then
        json = evaluation.support_turtle_format_log
      when 'cool_uri_rate' then
        json = evaluation.cool_uri_rate_log
      when 'number_of_statements' then
        json = evaluation.number_of_statements_log
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
    ranks = Endpoint.retrieved_at(date_param).pluck(:rank)
    ranks.each do |rank|
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
    points = 30

    evaluations = Evaluation.history(params, points)
    evaluations.each do |evaluation|
      date = evaluation.crawl_log.started_at
      rates = Evaluation.calc_rates(evaluation)
      availability.push(rates[0])
      freshness.push(rates[1])
      operation.push(rates[2])
      usefulness.push(rates[3])
      validity.push(rates[4])
      performance.push(rates[5])
      rank.push(evaluation.score.presence || 0)
      labels.push date
    end

    while labels.size < points
      evaluation = Evaluation.new
      rates = Evaluation.calc_rates(evaluation)
      availability.unshift(rates[0])
      freshness.unshift(rates[1])
      operation.unshift(rates[2])
      usefulness.unshift(rates[3])
      validity.unshift(rates[4])
      performance.unshift(rates[5])
      rank.unshift(0)
      labels.unshift(labels.first - 1)
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
    crawl_log = CrawlLog.started_at(date_param)
    if crawl_log.blank?
      render :json => {}
    else
      alives = crawl_log.evaluations.pluck(:alive)
      alives.each do |alive|
        alive ? count[:alive] += 1 : count[:dead] += 1
      end
      render :json => count
    end
  end

  def service_descriptions
    count = { :true => 0, :false => 0 }
    crawl_log = CrawlLog.started_at(date_param)
    if crawl_log.blank?
      render :json => {}
    else
      service_descriptions = crawl_log.evaluations.pluck(:service_description)
      service_descriptions.each do |sd|
        sd.present? ? count[:true] += 1 : count[:false] += 1
      end
      render :json => count
    end
  end


  def score_statistics
    last_crawled_date = date_param
    points = 10

    time_series = Endpoint.score_statistics_lastest_n(last_crawled_date, points)
    labels = time_series['date'].reverse
    averages = time_series['average'].values.reverse
    medians = time_series['median'].values.reverse

    while labels.size < points
      labels.unshift(labels.first - 1)
      averages.unshift(0.0)
      medians.unshift(0.0)
    end

    render :json => {
      :labels => labels,
      :datasets => [
        {
          :label => 'Average',
          :data => averages.map{|average| average.round(1)}
        },
        {
          :label => 'Median',
          :data => medians
        }
      ]
    }

  end

  def alive_statistics
    last_crawled_date = date_param
    points = 10

    time_series = Endpoint.alive_statistics_latest_n(last_crawled_date, points)
    labels = time_series['date'].reverse
    alive_data = time_series['alive'].values.reverse

    while labels.size < points
      labels.unshift(labels.first - 1)
      alive_data.unshift(0.0)
    end

    render :json => {
      :labels => labels,
      :datasets => [
        {
          label: 'Alive',
          data: alive_data.map{|alive| alive.round(1)}
        }
      ]
    }
  end

  def service_description_statistics
    last_crawled_date = date_param
    points = 10

    time_series = Endpoint.sd_statistics_latest_n(last_crawled_date, points)
    labels = time_series['date'].reverse
    have_data = time_series['sd'].values.reverse

    while labels.size < points
      labels.unshift(labels.first - 1)
      have_data.unshift(0.0)
    end

    render :json => {
      :labels => labels,
      :datasets => [
        {
          label: 'Have',
          data: have_data.map{|sd_score| sd_score.round(1)}
        }
      ]
    }
  end

  def score_ranking
    crawl_log = CrawlLog.started_at(date_param)
    if crawl_log.blank?
      render :json => {}
    else
      render json: crawl_log.evaluations.joins(:endpoint).order(endpointlist_param).pluck(:id, :'endpoints.id', :'endpoints.name', :'endpoints.url', :score)
    end
  end

  def issue_form
    @issue = GithubIssue.new
    @endpoint = Endpoint.find(params[:id])
  end

  def create_issue
    @issue = GithubIssue.new(params[:github_issue])
    @endpoint = Endpoint.find(params[:id])

    @issue.save(@endpoint)
    if @issue.errors.any?
      @success = false
      @error_message = @issue.errors.full_messages.join('').gsub("\n", '')
    else
      @success = true
      @redirect_url = "https://github.com/#{Rails.application.secrets.github_repo}/issues/#{@issue.id}"
    end
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
      @prev_evaluation = Evaluation.previous(@endpoint[:id], @evaluation[:retrieved_at])
      @next_evaluation = Evaluation.next(@endpoint[:id], @evaluation[:retrieved_at])

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
      @supported_language = JSON.parse(@evaluation.supported_language).join('<br/>') unless @evaluation.supported_language.nil?
      @linksets = JSON.parse(@evaluation.linksets) unless @evaluation.linksets.nil?
      @license = JSON.parse(@evaluation.license).join('<br/>') unless @evaluation.license.nil?
      @publisher = JSON.parse(@evaluation.publisher).join('<br/>') unless @evaluation.publisher.nil?
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def endpoint_params
      params.require(:endpoint).permit(:name, :url)
    end

    def date_param
      input_date = params[:date]
      endpoint_id = params[:id]
      evaluation_id = params[:evaluation_id]

      return Time.zone.parse(input_date) if input_date.present?

      if endpoint_id.present?
        evaluation = Evaluation.lookup(endpoint_id, evaluation_id)
        if evaluation && evaluation.crawl_log && (latest = evaluation.crawl_log.started_at)
          return latest
        end
      end

      if CrawlLog.latest && (latest = CrawlLog.latest.started_at)
        return latest
      end

      Time.now
    end

    def set_start_date
      evaluations = params[:id].nil? ? Evaluation.all : Evaluation.where(:endpoint_id => params[:id])
      oldest_evaluation = evaluations.order('retrieved_at ASC').first
      return if oldest_evaluation.nil?
      @start_date = oldest_evaluation.retrieved_at.strftime('%d-%m-%Y')
    end

    def endpointlist_param
      column = %w[name url score].include?(params[:column]) ? params[:column] : 'score'
      direction = %w[ASC DESC].include?(params[:direction]) ? params[:direction]
                                                            : %w[score].include?(params[:column]) || params[:column].blank? ? 'DESC'
                                                                                                                            : 'ASC'
      column + ' ' + direction
    end

    def set_metrics
      metrics = {
        data_collection: {count: 0, variation: 0},
        no_of_endpoints: {count: 0, variation: 0},
        active_endpoints: {count: 0, variation: 0},
        alive_rates: {count: 0, variation: 0},
        data_entries: {count: 0, variation: 0}
      }
      return metrics if CrawlLog.latest.blank?
      date = CrawlLog.latest.started_at

      metrics[:data_collection][:count] = CrawlLog.where.not(finished_at: nil).count
      metrics[:data_collection][:variation] = ((Time.zone.now - date) / 3600 / 24).round(0)
      number_of_endpoints_last_week = Endpoint.where.not('created_at >= ?', date.ago(7.days).beginning_of_day).count
      metrics[:no_of_endpoints][:count] = Endpoint.where('disable_crawling = ?', false).count
      metrics[:no_of_endpoints][:variation] = metrics[:no_of_endpoints][:count] - number_of_endpoints_last_week
      metrics[:active_endpoints][:count] = Evaluation.where(created_at: date.all_day, alive: true).count(:endpoint_id)
      metrics[:active_endpoints][:variation] = metrics[:active_endpoints][:count] - Evaluation.where(created_at: date.ago(1.days).all_day, alive: true).count(:endpoint_id)
      metrics[:alive_rates][:count] = ((metrics[:active_endpoints][:count].to_f / metrics[:no_of_endpoints][:count].to_f) * 100).round(0)
      metrics[:alive_rates][:variation] = metrics[:alive_rates][:count] - ((Evaluation.where(created_at: date.ago(7.days).all_day, alive: true).count(:endpoint_id).to_f / number_of_endpoints_last_week.to_f) * 100).round(0) if number_of_endpoints_last_week > 0
      metrics[:data_entries][:count] = Evaluation.where(created_at: date.all_day).sum(:number_of_statements)
      metrics[:data_entries][:variation] = metrics[:data_entries][:count] - Evaluation.where(created_at: date.ago(1.days).all_day).sum(:number_of_statements)
      metrics
    end
end
