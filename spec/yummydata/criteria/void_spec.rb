require 'spec_helper'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'VoID' do

      describe '#void_on_well_known_uri' do

        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::VoID } }
        let(:target) { test_class.new }

        before do
          @uri = URI('http://example.com/.well-known/void')
        end

        def read_file(file_name)
          cwd = File.expand_path('../../../data/yummydata/criteria/service_description', __FILE__)
          File.open(File.join(cwd, file_name)) do |file|
            file.read
          end
        end

        it 'should return void object when valid response is retrieved' do
          valid_ttl = read_file('good_turtle_01.ttl')
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get_recursive).with(@uri, anything, 10).and_return(response)
          allow(response).to receive(:each_key)
          allow(response).to receive(:body).and_return(valid_ttl)

          void = target.void_on_well_known_uri(@uri, 10)

          expect(void.license.include?('http://creativecommons.org/licenses/by/2.1/jp/')).to be true
          expect(void.publisher.include?('http://www.example.org/Publisher')).to be true
          expect(void.modified.include?("2016-01-01 10:00:00")).to be true
        end

        it 'should return false description object when invalid response is retrieved' do
          invalid_ttl = read_file('bad_turtle_01.ttl')
          response = double(Net::HTTPResponse)
          allow(target).to receive(:http_get_recursive).with(@uri, anything, 10).and_return(response)
          allow(response).to receive(:each_key)
          allow(response).to receive(:body).and_return(invalid_ttl)

          void = target.void_on_well_known_uri(@uri, 10)

          expect(void.license).to eq nil
          expect(void.publisher).to eq nil
          expect(void.modified).to eq nil
        end

      end
    end
  end
end
