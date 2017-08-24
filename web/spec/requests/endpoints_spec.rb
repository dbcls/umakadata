require 'rails_helper'

RSpec.describe "Endpoints", type: :request do
  describe "GET /endpoints" do
    it "works! (now write some real specs)" do
      get root_path
      expect(response).to have_http_status(200)
    end
  end

  describe "GET /api/endpoints/graph" do

    before do
      FactoryGirl.create_list(:endpoint, 100)
      FactoryGirl.create_list(:relation, 50)
    end

    it "works! (now write some real specs)" do
      get api_endpoints_graph_path

      expect(response).to have_http_status(200)
    end

    it "returns json data" do
      get api_endpoints_graph_path

      json = JSON.parse(response.body)

      expect(json.size).to eq 150
      expect(response).to have_http_status(200)
    end
  end
end
