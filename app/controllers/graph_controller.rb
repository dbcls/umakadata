class GraphController < ApplicationController
  def index
    params = index_params.to_h

    graphs = if params[:endpoint_id].present?
               Graph.where(endpoint_id: params[:endpoint_id].split(','))
             else
               Graph.all
             end

    data = graphs.order(:endpoint_id)
                 .map { |x| {
                   mode: x.mode,
                   graphs: x.graph_list,
                   endpoint: {
                     id: x.endpoint.id,
                     name: x.endpoint.name,
                     url: x.endpoint.endpoint_url,
                     enabled: x.endpoint.enabled
                   }
                 } }

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
