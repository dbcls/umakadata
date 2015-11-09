class EndpointsController < ApplicationController
  before_action :set_endpoint, only: [:show]

  def top
  end

  def search
    puts Endpoint.all.inspect
  end

  def show
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_endpoint
      @endpoint = Endpoint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def endpoint_params
      params.require(:endpoint).permit(:name, :url)
    end
end
