require 'spec_helper'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'LinkedDataRules' do

      describe '#response_time?' do

        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::LinkedDataRules } }
        let(:target) { test_class.new }

        before do
          @uri = URI('http://example.com')
        end

        it 'should return true when the response code is 200' do
          allow(target).to receive(:http_get).with(@uri, nil, 10)
            .and_return(Net::HTTPOK.new('1.1', '200', 'OK'))
          expect(target.response_time?(@uri, 10)).to be true
        end

      end
    end
  end
end

