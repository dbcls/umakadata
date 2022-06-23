class ExcludingGraphController < ApplicationController
  def index
    params = index_params.to_h

    excluding_graphs = if params[:endpoint_id].present?
                         ExcludingGraph.where(endpoint_id: params[:endpoint_id].split(','))
                       else
                         ExcludingGraph.all
                       end

    data = excluding_graphs.order(:endpoint_id)
                           .group_by { |x| x[:endpoint_id] }
                           .map do |endpoint_id, g|
      ep = Endpoint.find(endpoint_id)

      {
        endpoint: {
          id: ep.id,
          name: ep.name,
          url: ep.endpoint_url,
          enabled: ep.enabled
        },
        excluding_graphs: g.map(&:uri).sort,
      }
    end

    respond_to do |format|
      format.json do
        render json: data
      end
    end
  end

  private

  def index_params
    params.permit(:endpoint_id)
  end
end
