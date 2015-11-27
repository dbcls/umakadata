class EndpointsController < ApplicationController
  before_action :set_endpoint, only: [:show]

  def top
    @endpoints = Endpoint.all.order(:last_updated)
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
      @linked_data_rule_score = LinkedDataRule.calc_score(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def endpoint_params
      params.require(:endpoint).permit(:name, :url)
    end
end
