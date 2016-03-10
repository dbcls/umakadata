require 'spec_helper'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'ServiceDescription' do

      describe '#service_description' do

        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::ServiceDescription } }
        let(:target) { test_class.new }

        before do
          @uri = URI('http://example.com')
        end

        def read_file(file_name)
          cwd = File.expand_path('../../../data/yummydata/criteria/service_description', __FILE__)
          File.open(File.join(cwd, file_name)) do |file|
            file.read
          end
        end

        it 'should return service description object when valid response is retrieved' do
          valid_ttl = read_file('good_turtle_01.ttl')
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get).with(@uri, anything, 10).and_return(response)
          allow(response).to receive(:each_key)
          allow(response).to receive(:body).and_return(valid_ttl)

          service_description = target.service_description(@uri, 10)

          expect(service_description.type).to eq Yummydata::DataFormat::TURTLE
          expect(service_description.text).to eq valid_ttl
        end

        it 'should return false description object when invalid response is retrieved' do
          invalid_ttl = read_file('bad_turtle_01.ttl')
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get).with(@uri, anything, 10).and_return(response)
          allow(response).to receive(:each_key)
          allow(response).to receive(:body).and_return(invalid_ttl)

          service_description = target.service_description(@uri, 10)

          expect(service_description.type).to eq Yummydata::DataFormat::UNKNOWN
          expect(service_description.text).to eq nil
        end

      end
    end
  end
end
