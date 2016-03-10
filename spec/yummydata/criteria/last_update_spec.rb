require 'spec_helper'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'LastUpdate' do

      describe '#last_modified' do

        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::LastUpdate } }
        let(:target) { test_class.new }

        before do
          @uri = URI("http://example.com")
        end

        # it 'should return not nil' do
        #   sd_proc = double(Yummydata::Criteria::ServiceDescription)
        #   sd_data = double(Yummydata::ServiceDescription)
        #   response = double(Net::HTTPResponse)
        #   # allow(sd_proc).to receive(:service_description).and_return(Yummydata::ServiceDescription)
        #   # allow(sd_data).tp receive(:modified).and_return()
        #   allow(sd_data).to receive(:initialize).with(response).and_return(sd_data)
        #   allow(target).to receive(:service_description).with(nil, 10).and_return(sd_data)
        #   # allow(target).to receive(:modified).and_return('2016-01-01 10:00:00')
        #   expect(target.last_modified).to eq '2016-01-01 10:00:00'
        # end

        it 'should return not nil when uri returns service_description modified' do
          target.instance_variable_set(:@uri, @uri)
          sd = double(Yummydata::Criteria::ServiceDescription)
          allow(sd).to receive(:modified).and_return("2016-01-01 10:00:00")
          allow(target).to receive(:service_description).and_return(sd)

          expect(target.last_modified).to eq '2016-01-01 10:00:00'
        end

        it 'should return not nil when uri returns void modified' do
          target.instance_variable_set(:@uri, @uri)
          sd = double(Yummydata::Criteria::ServiceDescription)
          void = double(Yummydata::Criteria::VoID)
          allow(sd).to receive(:modified).and_return(nil)
          allow(void).to receive(:modified).and_return('2016-01-01 10:00:00')
          allow(target).to receive(:service_description).and_return(sd)
          allow(target).to receive(:void_on_well_known_uri).and_return(void)

          expect(target.last_modified).to eq '2016-01-01 10:00:00'
        end

        it 'should return nil' do
          target.instance_variable_set(:@uri, @uri)
          sd = double(Yummydata::Criteria::ServiceDescription)
          void = double(Yummydata::Criteria::VoID)
          allow(sd).to receive(:modified).and_return(nil)
          allow(void).to receive(:modified).and_return(nil)
          allow(target).to receive(:service_description).and_return(sd)
          allow(target).to receive(:void_on_well_known_uri).and_return(void)

          expect(target.last_modified).to  be_nil
        end

      end
    end
  end
end
