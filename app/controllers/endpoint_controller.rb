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
    to = date_for_crawl[:current]
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

  def info
    @date        = date_param
    count        = PrefixFilter.where(endpoint_id: @endpoint[:id]).count()
    @uri_indexed = count > 0
    render layout: false
  end

end
