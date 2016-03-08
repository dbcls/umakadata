require 'spec_helper'
require 'yummydata/criteria/metadata'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'Metadata' do

      describe '#score?' do

        before do
          @target = Yummydata::Criteria::Metadata.new('http://example.com')
        end

        it 'should returns 0 if no graph is found' do
          allow(@target).to receive(:list_of_graph_uris).and_return([])

          score = @target.score

          expect(score).to eq 0
        end

        it 'should return 100 if one graph is found and everything is found in the graph' do
          allow(@target).to receive(:list_of_graph_uris).and_return(['GRAPH1'])
          allow(@target).to receive(:classes_on_graph).and_return(['CLASS'])
          allow(@target).to receive(:list_of_labels_of_classes).and_return(['LABEL'])
          allow(@target).to receive(:list_of_datatypes).and_return(['DATATYPE'])
          allow(@target).to receive(:list_of_properties_on_graph).and_return(['PROPERTY'])

          score = @target.score

          expect(score).to eq 100
        end

        it 'should return 50 if two graph is found and everything is found in one graph and nothing in the other' do
          allow(@target).to receive(:list_of_graph_uris).and_return(['GRAPH1', 'GRAPH2'])
          allow(@target).to receive(:classes_on_graph).with('GRAPH1').and_return(['CLASS'])
          allow(@target).to receive(:classes_on_graph).with('GRAPH2').and_return([])
          allow(@target).to receive(:list_of_labels_of_classes).with('GRAPH1', ['CLASS']).and_return(['LABEL'])
          allow(@target).to receive(:list_of_labels_of_classes).with('GRAPH2', []).and_return([])
          allow(@target).to receive(:list_of_datatypes).with('GRAPH1').and_return(['DATATYPE'])
          allow(@target).to receive(:list_of_datatypes).with('GRAPH2').and_return([])
          allow(@target).to receive(:list_of_properties_on_graph).with('GRAPH1').and_return(['PROPERTY'])
          allow(@target).to receive(:list_of_properties_on_graph).with('GRAPH2').and_return([])

          score = @target.score

          expect(score).to eq 50
        end

      end
    end
  end
end
