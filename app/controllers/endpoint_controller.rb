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
  end

  # GET /endpoint/statistics
  def statistics
    to = current_date || Date.current
    from = 10.days.ago(to)

    begin
      data = (from..to).map do |day|
        key = day.strftime('%m/%d')
        data = if (c = Crawl.finished.on(day))
                 [c.score_average.to_i, c.score_median.round(0), (c.alive_rate * 100).to_i, (c.service_descriptions_rate * 100).to_i]
               else
                 Array.new(4) { nil }
               end
        [key, data]
      end
      render json: data.to_h
    rescue
      render json: { error: '500 Internal Server Error' }, status: 500
    end
  end

  # GET /endpoint/:id/scores
  def scores
    date = current_date || Date.current
    crawl = Crawl.on(date)
    evaluation = crawl&.evaluations&.find_by(endpoint_id: params[:id])

    render json: {
      date: date,

      scores: evaluation&.scores&.map { |k, v| [k, v.to_i] }.to_h,
      average: crawl&.scores_average&.map { |k, v| [k, v.to_i] }.to_h
    }
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
  end
end
