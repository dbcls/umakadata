require 'spec_helper'

describe Yummydata do

  describe '#is_alive?' do

    before do
      @endpoint = Yummydata::Endpoint.new('http://example.com/sparql')

      @mock_http = double('net/HTTP')
      # force Net::HTTP class to instantiate mocked HTTP object
      allow(Net::HTTP).to receive(:new).and_return(@mock_http)
    end

    it 'should be true when the response to GET request is 200 status code' do
      # mocked HTTP object returns Net::HTTPOK that represents #200 status code
      allow(@mock_http).to receive(:get).and_return(Net::HTTPOK.new('1.1', '200', 'OK'))

      expect(@endpoint.is_alive?).to be true
    end

    it 'should be false when the response to GET request is NOT 200 status code' do
      # mocked HTTP object returns Net::HTTPNotFound that represents #404 status code
      allow(@mock_http).to receive(:get).and_return(Net::HTTPNotFound.new('1.1', '404', 'Not Found'))

      expect(@endpoint.is_alive?).to be false
    end

    it 'should be false when the Net::HTTP#get method raises an exception' do
      allow(@mock_http).to receive(:get).and_raise("yucky!")

      expect(@endpoint.is_alive?).to be false
    end

  end

end
