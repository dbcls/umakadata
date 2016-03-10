require 'spec_helper'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'LastUpdate' do

      describe '#last_modified' do

        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::LastUpdate } }
        let(:target) { test_class.new }

        it 'should return not nil' do
          allow(target).to receive(:response_time).with(Yummydata::Criteria::ExecutionTime::BASE_QUERY).and_return(1000)
          allow(target).to receive(:response_time).with(Yummydata::Criteria::ExecutionTime::TARGET_QUERY).and_return(10000)
          expect(target.execution_time(@uri)).not_to be_nil
        end

      end
    end
  end
end
