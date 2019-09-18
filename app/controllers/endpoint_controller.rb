class EndpointController < ApplicationController
  # GET /endpoint
  def index
    @date = (v = params[:date]) ? Date.parse(v) : Crawl.latest.started_at.to_date
    @crawl = Crawl.find_by(started_at: @date.all_day)

    respond_to do |format|
      format.html
      format.json do
        if @crawl.present?
          render formats: 'json', handlers: 'jbuilder'
        else
          render json: { error: '404 Not Found' }, status: 404
        end
      end
    end
  end

  def show
  end
end
