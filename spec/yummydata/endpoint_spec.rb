require 'spec_helper'

describe Yummydata do

  describe 'Endpoint' do

    describe '#alive?' do

      before do
        @endpoint = Yummydata::Endpoint.new('http://example.com/sparql')

        @mock_http = double('net/HTTP')

        # force Net::HTTP class to instantiate mocked HTTP object
        allow(Net::HTTP).to receive(:new).and_return(@mock_http)
        allow(@mock_http).to receive(:open_timeout=).with(anything)
      end

      it 'should be true when the response to GET request is 200 status code' do
        # mocked HTTP object returns Net::HTTPOK that represents #200 status code
        allow(@mock_http).to receive(:get).and_return(Net::HTTPOK.new('1.1', '200', 'OK'))

        expect(@endpoint.alive?).to be true
      end

      it 'should be false when the response to GET request is NOT 200 status code' do
        # mocked HTTP object returns Net::HTTPNotFound that represents #404 status code
        allow(@mock_http).to receive(:get).and_return(Net::HTTPNotFound.new('1.1', '404', 'Not Found'))

        expect(@endpoint.alive?).to be false
      end

      it 'should be false when the Net::HTTP#get method raises an exception' do
        allow(@mock_http).to receive(:get).and_raise("yucky!")

        expect(@endpoint.alive?).to be false
      end

    end

  end

  describe 'ServiceDescription' do

    def read_file(file_name)
      cwd = File.expand_path('../', __FILE__)
      File.open(File.join(cwd, file_name)) do |file|
        file.read
      end
    end

    describe '#initialize' do

      before do
        @mock_response = double('net/HTTPResponse')
        allow(@mock_response).to receive(:nil?).and_return(false)
        allow(@mock_response).to receive(:each_key)
      end

      # TODO assetion for response header
      it 'parse valid turtle text' do
        test_string = read_file('sd_samples/good_turtle_01.ttl')
        allow(@mock_response).to receive(:body).and_return(test_string)

        service_description = Yummydata::ServiceDescription.new(@mock_response)

        expect(service_description.type).to eq 'ttl'
        expect(service_description.value).to eq test_string
      end

      it 'fail to parse invalid turtle text' do
        test_string = read_file('sd_samples/bad_turtle_01.ttl')
        allow(@mock_response).to receive(:body).and_return(test_string)

        service_description = Yummydata::ServiceDescription.new(@mock_response)

        expect(service_description.type).to eq 'unknown'
        expect(service_description.value).to be nil
      end

      it 'parse valid xml' do
        test_string = read_file('sd_samples/good_xml_01.xml')
        allow(@mock_response).to receive(:body).and_return(test_string)

        service_description = Yummydata::ServiceDescription.new(@mock_response)

        expect(service_description.type).to eq 'xml'
        expect(service_description.value).to eq test_string
      end

      it 'fail to parse invalid xml' do
        test_string = read_file('sd_samples/bad_xml_01.xml')
        allow(@mock_response).to receive(:body).and_return(test_string)

        service_description = Yummydata::ServiceDescription.new(@mock_response)

        expect(service_description.type).to eq 'unknown'
        expect(service_description.value).to be nil
      end


    end

  end

end
