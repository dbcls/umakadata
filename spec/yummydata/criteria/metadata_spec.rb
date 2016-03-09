require 'spec_helper'
require 'yummydata/criteria/metadata'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'Metadata' do

      describe '#score?' do

        before do
          @target = Yummydata::Criteria::Metadata.new('http://example.com')
        end

        it 'should returns empty metadata if failed to retrieve graph list' do
          allow(@target).to receive(:list_of_graph_uris).and_return([])

          score = @target.retrieve

          expect(score).to be_empty
        end

        it 'should return 100 if one graph is found and everything is found in the graph' do
          allow(@target).to receive(:list_of_graph_uris).and_return(['GRAPH1'])
          allow(@target).to receive(:classes_on_graph).and_return(['CLASS1'])
          allow(@target).to receive(:list_of_labels_of_classes).and_return(['LABEL1'])
          allow(@target).to receive(:list_of_datatypes).and_return(['DATATYPE1'])
          allow(@target).to receive(:list_of_properties_on_graph).and_return(['PROPERTY1'])

          metadata = @target.retrieve

          expect(metadata).to have_key('GRAPH1')
          expect(metadata['GRAPH1'][:classes]).to include('CLASS1')
          expect(metadata['GRAPH1'][:labels]).to include('LABEL1')
          expect(metadata['GRAPH1'][:datatypes]).to include('DATATYPE1')
          expect(metadata['GRAPH1'][:properties]).to include('PROPERTY1')
        end

        it 'should return 50 if two graph is found and everything is found in one graph and nothing in the other' do
          allow(@target).to receive(:list_of_graph_uris).and_return(['GRAPH1', 'GRAPH2'])
          allow(@target).to receive(:classes_on_graph).with('GRAPH1').and_return(['CLASS1'])
          allow(@target).to receive(:classes_on_graph).with('GRAPH2').and_return([])
          allow(@target).to receive(:list_of_labels_of_classes).with('GRAPH1', ['CLASS1']).and_return(['LABEL1'])
          allow(@target).to receive(:list_of_labels_of_classes).with('GRAPH2', []).and_return([])
          allow(@target).to receive(:list_of_datatypes).with('GRAPH1').and_return(['DATATYPE1'])
          allow(@target).to receive(:list_of_datatypes).with('GRAPH2').and_return([])
          allow(@target).to receive(:list_of_properties_on_graph).with('GRAPH1').and_return(['PROPERTY1'])
          allow(@target).to receive(:list_of_properties_on_graph).with('GRAPH2').and_return([])

          metadata = @target.retrieve

          expect(metadata).to have_key('GRAPH1')
          expect(metadata['GRAPH1'][:classes]).to include('CLASS1')
          expect(metadata['GRAPH1'][:labels]).to include('LABEL1')
          expect(metadata['GRAPH1'][:datatypes]).to include('DATATYPE1')
          expect(metadata['GRAPH1'][:properties]).to include('PROPERTY1')
          expect(metadata['GRAPH2'][:classes]).to be_empty
          expect(metadata['GRAPH2'][:labels]).to be_empty
          expect(metadata['GRAPH2'][:datatypes]).to be_empty
          expect(metadata['GRAPH2'][:properties]).to be_empty
        end

      end
    end
  end
end
