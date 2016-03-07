require 'spec_helper'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'LinkedDataRules' do

      describe '#response_time' do

        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::LinkedDataRules } }
        let(:target) { test_class.new }

        before do
          @uri = URI("http://dbpedia.org/sparql")
          @ask_query = <<-'SPARQL'
ASK{}
SPARQL

          @target_query = <<-'SPARQL'
SELECT DISTINCT
  ?g
WHERE {
  GRAPH ?g {
    ?s ?p ?o
  }
}
SPARQL
        end

        it 'should return not nil' do
          allow(target).to receive(:get_response_time).with(@ask_query)
            .and_return(1000)
          allow(target).to receive(:get_response_time).with(@target_query)
            .and_return(10000)
          expect(target.response_time(@uri)).not_to be_nil
        end

        it 'should return nil when the response time of ask query is nil' do
          allow(target).to receive(:get_response_time).with(@ask_query)
            .and_return(nil)
          allow(target).to receive(:get_response_time).with(@target_query)
            .and_return(10000)
          expect(target.response_time(@uri)).to be_nil
        end

        it 'should return nil when the response time of target query is nil' do
          allow(target).to receive(:get_response_time).with(@ask_query)
            .and_return(1000)
          allow(target).to receive(:get_response_time).with(@target_query)
            .and_return(nil)
          expect(target.response_time(@uri)).to be_nil
        end

        it 'should return nil when the response time of ask query is greater than the one of target query' do
          allow(target).to receive(:get_response_time).with(@ask_query)
            .and_return(10000)
          allow(target).to receive(:get_response_time).with(@target_query)
            .and_return(1000)
          expect(target.response_time(@uri)).to be_nil
        end

        it 'should return 9000 when the response time of ask query is 1000 and the one of target query is 10000' do
          allow(target).to receive(:get_response_time).with(@ask_query)
            .and_return(1000)
          allow(target).to receive(:get_response_time).with(@target_query)
            .and_return(10000)
          expect(target.response_time(@uri)).to eq 9000
        end

        it 'should return 0 when the response time of ask query is 10000 and the one of target query is 10000' do
          allow(target).to receive(:get_response_time).with(@ask_query)
            .and_return(10000)
          allow(target).to receive(:get_response_time).with(@target_query)
            .and_return(10000)
          expect(target.response_time(@uri)).to eq 0
        end

          describe '#get_response_time' do
            it 'should return a numeric more than 0' do
              target.prepare(@uri)
              expect(target.get_response_time(@ask_query)).to eq 0
            end
          end
      end
    end
  end
end

