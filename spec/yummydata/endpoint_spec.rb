require 'spec_helper'

describe Yummydata do

  describe 'is_alive?' do

    it 'should be true when the response to GET request is 200 status code' do
      mock_http = double('net/HTTP')
      # mocked HTTP object returns Net::HTTPOK that represents #200 status code
      allow(mock_http).to receive(:get).and_return(Net::HTTPOK.new('1.1', '200', 'OK'))
      # force Net::HTTP class to instantiate mocked HTTP object
      allow(Net::HTTP).to receive(:new).and_return(mock_http)

      endpoint = Yummydata::Endpoint.new('http://example.com/sparql')

      expect(endpoint.is_alive?).to be true
    end

    it 'should be false when the response to GET request is NOT 200 status code' do
      mock_http = double('net/HTTP')
      # mocked HTTP object returns Net::HTTPNotFound that represents #404 status code
      allow(mock_http).to receive(:get).and_return(Net::HTTPNotFound.new('1.1', '404', 'Not Found'))
      # force Net::HTTP class to instantiate mocked HTTP object
      allow(Net::HTTP).to receive(:new).and_return(mock_http)

      endpoint = Yummydata::Endpoint.new('http://example.com/sparql')

      expect(endpoint.is_alive?).to be false
    end

  end

end
