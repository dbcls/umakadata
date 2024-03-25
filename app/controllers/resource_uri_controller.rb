class ResourceUriController < ApplicationController
  # GET /api/resource_uri/search
  def search
    params = search_params.to_h

    records = if params[:endpoint_id].present?
                ResourceURI.where(endpoint_id: params[:endpoint_id].split(','))
              else
                ResourceURI.all
              end

    data = records.order(:endpoint_id, :id)
                  .map do |x|
      {
        uri: x.uri,
        allow: x.allow,
        deny: x.deny,
        regex: x.regex,
        case_insensitive: x.case_insensitive,
        endpoint: {
          id: x.endpoint.id,
          name: x.endpoint.name,
          url: x.endpoint.endpoint_url,
          enabled: x.endpoint.enabled
        }
      }
    end

    respond_to do |format|
      format.json do
        render json: data
      end
    end
  end

  private

  def search_params
    params.permit(:endpoint_id)
  end
end
