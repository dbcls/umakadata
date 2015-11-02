require 'rails_helper'

RSpec.describe "Endpoints", type: :request do
  describe "GET /endpoints" do
    it "works! (now write some real specs)" do
      get endpoints_path
      expect(response).to have_http_status(200)
    end
  end
end
