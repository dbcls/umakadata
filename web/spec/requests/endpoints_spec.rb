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
      allow(Endpoint).to receive(:create_issue).and_return(true)

      # create endpoints without relations
      FactoryBot.create_list(:endpoint, 50)

      # create endpoints with relations
      50.times.each do
        FactoryBot.create(:endpoint) do |e|
          e.relations.create(FactoryBot.attributes_for(:relation))
        end
      end
    end

    it "returns json array with 150 elements" do
      get api_endpoints_graph_path

      json = JSON.parse(response.body)

      expect(json.size).to eq 150
      expect(response).to have_http_status(200)
    end
  end
end
