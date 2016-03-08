require 'spec_helper'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'ResponseTime' do

      ASK_QUERY = <<-'SPARQL'
ASK{}
SPARQL

      TARGET_QUERY = <<-'SPARQL'
SELECT DISTINCT
  ?g
WHERE {
  GRAPH ?g {
    ?s ?p ?o
  }
}
SPARQL

       MALFORMED_QUERY = <<-'SPARQL'
ASK{
SPARQL
      describe '#execution_time' do


        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::ResponseTime } }
        let(:target) { test_class.new }

        before do
          @uri = URI("http://dbpedia.org/sparql")
        end

        it 'should return not nil' do
          allow(target).to receive(:response_time).with(ASK_QUERY)
            .and_return(1000)
          allow(target).to receive(:response_time).with(TARGET_QUERY)
            .and_return(10000)
          expect(target.execution_time(@uri)).not_to be_nil
        end

        it 'should return nil when the response time of ask query is nil' do
          allow(target).to receive(:response_time).with(ASK_QUERY)
            .and_return(nil)
          allow(target).to receive(:response_time).with(TARGET_QUERY)
            .and_return(10000)
          expect(target.execution_time(@uri)).to be_nil
        end

        it 'should return nil when the response time of target query is nil' do
          allow(target).to receive(:response_time).with(ASK_QUERY)
            .and_return(1000)
          allow(target).to receive(:response_time).with(TARGET_QUERY)
            .and_return(nil)
          expect(target.execution_time(@uri)).to be_nil
        end

        it 'should return nil when the response time of ask query is greater than the one of target query' do
          allow(target).to receive(:response_time).with(ASK_QUERY)
            .and_return(10000)
          allow(target).to receive(:response_time).with(TARGET_QUERY)
            .and_return(1000)
          expect(target.execution_time(@uri)).to be_nil
        end

        it 'should return 9000 when the response time of ask query is 1000 and the one of target query is 10000' do
          allow(target).to receive(:response_time).with(ASK_QUERY)
            .and_return(1000)
          allow(target).to receive(:response_time).with(TARGET_QUERY)
            .and_return(10000)
          expect(target.execution_time(@uri)).to eq 9000
        end

        it 'should return 0 when the response time of ask query is 10000 and the one of target query is 10000' do
          allow(target).to receive(:response_time).with(ASK_QUERY)
            .and_return(10000)
          allow(target).to receive(:response_time).with(TARGET_QUERY)
            .and_return(10000)
          expect(target.execution_time(@uri)).to eq 0
        end

	describe '#response_time' do
          it 'should return nil' do
            target.instance_varaiable_set(:@uri, @uri)
            target.prepare(@uri)
	    expect(target.response_time(MALFORMED_QUERY)).to eq 0
	  end
	end

      end
    end
  end
end

