class EndpointController < ApplicationController
  include DatePicker

  # GET /endpoint
  def index
    @date = date_for_crawl
    @evaluations = if (crawl = Crawl.on(@date[:current])).present?
                     Evaluation.where(crawl_id: crawl.id)
                   end

    respond_to do |format|
      format.html
      format.json do
        if @evaluations.present?
          render formats: 'json', handlers: 'jbuilder'
        else
          render json: { error: '404 Not Found' }, status: 404
        end
      end
    end
  end

  # GET /endpoint/:id
  def show
    @date = date_for_endpoint(params[:id])
    @endpoint = Endpoint.find(params[:id])
    @evaluation = Crawl.on(@date[:current])&.evaluations&.find_by(endpoint_id: params[:id])
    @issue = GithubIssue.new if Rails.application.credentials.github_repo.present? && @endpoint.issue_id.present?

    if @evaluation.blank?
      render :file => "#{Rails.root}/public/404.html", layout: false, status: :not_found
    end
  end

  # GET /endpoint/search
  # GET /api/endpoint/search
  def search
    @date = date_for_crawl

    @search_form = SearchForm.new(search_params)
    @search_form.date ||= @date[:current]

    @endpoints = @search_form.search

    respond_to do |format|
      format.html
      format.json do
        render formats: 'json', handlers: 'jbuilder'
      end
    end
  rescue
    respond_to do |format|
      format.html do
        render :file => "#{Rails.root}/public/500.html", layout: false, status: :internal_server_error
      end
      format.json do
        render json: { error: '500 Internal Server Error' }, status: 500
      end
    end
  end

  # GET /endpoint/statistics
  def statistics
    @to = current_date || Date.current
    @from = 13.days.ago(@to)
  end

  # GET /endpoint/graph
  # GET /api/endpoints/graph
  def graph
    respond_to do |format|
      format.html
      format.json do
        render json: DatasetRelation.graph
      end
    end
  rescue
    respond_to do |format|
      format.html do
        render :file => "#{Rails.root}/public/500.html", layout: false, status: :internal_server_error
      end
      format.json do
        render json: { error: '500 Internal Server Error' }, status: 500
      end
    end
  end

  # GET /endpoint/:id/scores
  def scores
    date = current_date || Date.current
    crawl = Crawl.on(date)
    evaluation = crawl&.evaluations&.find_by(endpoint_id: params[:id])
    begin
      render json: {
        date: date,

        scores: evaluation&.scores&.map { |k, v| [k, v.to_i] }.to_h,
        average: crawl&.scores_average&.map { |k, v| [k, v.to_i] }.to_h
      }
    rescue
      render json: { error: '500 Internal Server Error' }, status: 500
    end
  end

  # GET /endpoint/:id/histories
  def histories
    to = current_date || Date.current
    from = 30.days.ago(to)

    crawl = Crawl
              .eager_load(:evaluations)
              .finished
              .where(started_at: (from.beginning_of_day)..(to.end_of_day))
              .where(evaluations: { endpoint_id: params[:id] })

    begin
      render json: {
        date: {
          from: from,
          to: to
        },
        labels: crawl.map { |x| x.started_at.to_date.to_formatted_s },
        datasets: [
          {
            label: 'availability',
            data: crawl.map { |x| x.evaluations.first.availability },
          },
          {
            label: 'freshness',
            data: crawl.map { |x| x.evaluations.first.freshness },
          },
          {
            label: 'operation',
            data: crawl.map { |x| x.evaluations.first.operation },
          },
          {
            label: 'usefulness',
            data: crawl.map { |x| x.evaluations.first.usefulness },
          },
          {
            label: 'validity',
            data: crawl.map { |x| x.evaluations.first.validity },
          },
          {
            label: 'performance',
            data: crawl.map { |x| x.evaluations.first.performance },
          },
        ]
      }
    rescue
      render json: { error: '500 Internal Server Error' }, status: 500
    end
  end

  CURL_GET_TEMPLATE = 'curl -L -H "Accept: %s" "%s"'
  CURL_POST_TEMPLATE = 'curl -L -XPOST -H "Accept: %s" "%s" -d "%s"'

  # GET /endpoint/:id/log/:name
  def log
    @date = date_for_crawl[:current]
    @name = params[:name]

    @endpoint = Endpoint.find(params[:id])
    @evaluation = Crawl.on(@date)&.evaluations&.find_by(endpoint_id: params[:id])
    @measurement = @evaluation&.measurements&.find_by('measurements.name LIKE ?', "%.#{@name}")

    respond_to do |format|
      format.html do
        if @endpoint.blank? || @evaluation.blank? || @measurement.blank?
          render file: "#{Rails.root}/public/404.html", layout: false, status: :not_found
          return
        end
      end

      format.json do
        if @endpoint.blank? || @evaluation.blank? || @measurement.blank?
          render json: { error: '404 Not Found' }, status: 404
          return
        end

        columns = %w[id name comment request response elapsed_time trace warnings]
        columns << 'exceptions' if admin_user_signed_in?

        begin
          page = [params[:page].to_i, 1].max
          activities = @measurement.activities.order(:id).offset((page - 1) * 10).limit(10)
          more = @measurement.activities.count > page * 10

          data = activities.map { |x| x.attributes.slice(*columns) }

          data.each do |x|
            next unless (request = x['request']).is_a?(Hash)

            if (method = request.dig(:method)&.upcase) == 'POST'
              if (url = request.dig(:url)) && (accept = request.dig(:headers, :Accept)) && (body = request.dig(:body))
                x['curl'] = format(CURL_POST_TEMPLATE, accept, url, body)
              end
            elsif method == 'GET'
              if (url = request.dig(:url)) && (accept = request.dig(:headers, :Accept))
                x['curl'] = format(CURL_GET_TEMPLATE, accept, url)
              end
            end
          end

          render json: {
            date: @date,
            page: page,
            data: data,
            more: more
          }
        rescue
          render json: { error: '500 Internal Server Error' }, status: 500
        end
      end
    end
  end

  # POST /endpoint/:id/forum
  def create_forum
    @issue = GithubIssue.new(create_forum_params)
    @endpoint = Endpoint.find(params[:id])

    session[:issue_info] = {
      title: @issue.title,
      description: @issue.description,
      endpoint_name: @endpoint.id.to_s
    }

    session[:prev_url] = request.referer

    redirect_to '/auth/github'
  end

  private

  def search_params
    params
      .fetch(:search_form, params)
      .permit(:name, :resource_uri, :element_type, :date, :score_lower, :score_upper, :alive_rate_lower,
              :alive_rate_upper, :cool_uri_rate_lower, :cool_uri_rate_upper, :ontology_lower, :ontology_upper,
              :metadata_lower, :metadata_upper, :service_description, :void, :content_negotiation, :html, :turtle, :xml,
              rank: [])
  end

  def create_forum_params
    params.require(:github_issue).permit(:title, :description)
  end
end
