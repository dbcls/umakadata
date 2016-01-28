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

  def scores
    count = Hash.new(0)
    Endpoint.all.each do |endpoint|
      rank = Score.where(endpoint_id: endpoint.id).last.rank
      count[rank] += 1;
    end

    render :json => scores_json(count)
  end

  def alive
    count = Hash.new(0)
    Endpoint.all.each do |endpoint|
      alive = CheckLog.where(endpoint_id: endpoint.id).last.alive
      alive ? count[:alive] += 1 : count[:dead] += 1
    end

    render :json => alive_json(count)
  end

  def service_descriptions
    count = Hash.new(0)
    Endpoint.all.each do |endpoint|
      sd = CheckLog.where(endpoint_id: endpoint.id).last.service_description
      sd.present? ? count[:true] += 1 : count[:false] += 1
    end

    render :json => service_descriptions_json(count)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_endpoint
      @endpoint = Endpoint.find(params[:id])
      check_log = CheckLog.where(endpoint_id: params[:id]).last
      @liveness = check_log.alive
      @service_description = check_log.service_description
      @response_header = check_log.response_header
      @has_service_description = @service_description.present?
      @linked_data_rule_score = LinkedDataRule.calc_score(params[:id])
      @score = Score.where(:endpoint_id => params[:id]).order(created_at: :desc).first
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def endpoint_params
      params.require(:endpoint).permit(:name, :url)
    end

    def scores_json(count)
      [
        {
          value: count[1],
          color: "#1D2088",
          highlight: "#6356A3",
          label: "Rank A"
        },
        {
          value: count[2],
          color: "#00A0E9",
          highlight: "#00B9EF",
          label: "Rank B"
        },
        {
          value: count[3],
          color: "#009944",
          highlight: "#3EB37",
          label: "Rank C"
        },
        {
          value: count[4],
          color: "#FFF100",
          highlight: "#FFF462",
          label: "Rank D"
        },
        {
          value: count[5],
          color: "#E60012",
          highlight: "#FF5A5E",
          label: "Rank E"
        }
      ]
    end

    def alive_json(count)
      [
        {
          value: count[:alive],
          color: "#00A0E9",
          highlight: "#00B9EF",
          label: "Alive"
        },
        {
          value: count[:dead],
          color: "#E60012",
          highlight: "#FF5A5E",
          label: "Dead"
        }
      ]
    end

    def service_descriptions_json(count)
      [
        {
          value: count[:true],
          color: "#00A0E9",
          highlight: "#00B9EF",
          label: "Have"
        },
        {
          value: count[:false],
          color: "#E60012",
          highlight: "#FF5A5E",
          label: "Do not have"
        }
      ]
    end

end
