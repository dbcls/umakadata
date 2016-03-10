require 'spec_helper'
require 'yummydata/criteria/metadata'

describe 'Yummydata' do
  describe 'Criteria' do
    describe 'Metadata' do

      describe '#metadata?' do

        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::Metadata } }
        let(:target) { test_class.new }

        before do
          @uri = URI('http://example.com')
        end

        it 'should returns empty metadata if failed to retrieve graph list' do
          allow(target).to receive(:list_of_graph_uris).and_return([])

          metadata = target.metadata(@uri)

          expect(metadata).to be_empty
        end

        it 'should returns metadata which contains retrieved items for when a graph is retrieved' do
          allow(target).to receive(:list_of_graph_uris).and_return(['GRAPH1'])
          allow(target).to receive(:classes_on_graph).and_return(['CLASS1'])
          allow(target).to receive(:list_of_labels_of_classes).and_return(['LABEL1'])
          allow(target).to receive(:list_of_datatypes).and_return(['DATATYPE1'])
          allow(target).to receive(:list_of_properties_on_graph).and_return(['PROPERTY1'])

          metadata = target.metadata(@uri)

          expect(metadata).to have_key('GRAPH1')
          expect(metadata['GRAPH1'][:classes]).to include('CLASS1')
          expect(metadata['GRAPH1'][:labels]).to include('LABEL1')
          expect(metadata['GRAPH1'][:datatypes]).to include('DATATYPE1')
          expect(metadata['GRAPH1'][:properties]).to include('PROPERTY1')
        end

        it 'should returns metadata which contains retrieved items for when multiple graphs are retrieved' do
          allow(target).to receive(:list_of_graph_uris).and_return(['GRAPH1', 'GRAPH2'])
          allow(target).to receive(:classes_on_graph).with(anything, 'GRAPH1').and_return(['CLASS1'])
          allow(target).to receive(:classes_on_graph).with(anything, 'GRAPH2').and_return([])
          allow(target).to receive(:list_of_labels_of_classes).with(anything, 'GRAPH1', ['CLASS1']).and_return(['LABEL1'])
          allow(target).to receive(:list_of_labels_of_classes).with(anything, 'GRAPH2', []).and_return([])
          allow(target).to receive(:list_of_datatypes).with(anything, 'GRAPH1').and_return(['DATATYPE1'])
          allow(target).to receive(:list_of_datatypes).with(anything, 'GRAPH2').and_return([])
          allow(target).to receive(:list_of_properties_on_graph).with(anything, 'GRAPH1').and_return(['PROPERTY1'])
          allow(target).to receive(:list_of_properties_on_graph).with(anything, 'GRAPH2').and_return([])

          metadata = target.metadata(@uri)

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

      describe '#score_metadata?' do

        let(:test_class) { Struct.new(:target) { include Yummydata::Criteria::Metadata } }
        let(:target) { test_class.new }

        it 'should return 0 if metadata is empty' do
          metadata = {}

          score = target.score_metadata(metadata)

          expect(score).to be_within(0.001).of(0.0)
        end

        it 'should return 0 if metadata contains a graph which does not any classes, labels, properties and datatypes' do
          metadata = {GRAPH: {classes: [], labels: [], properties: [], datatypes: []}}

          score = target.score_metadata(metadata)

          expect(score).to be_within(0.001).of(0.0)
        end

        it 'should return 25 if metadata contains a graph which has a class' do
          metadata = {GRAPH: {classes: ['CLASS1'], labels: [], properties: [], datatypes: []}}

          score = target.score_metadata(metadata)

          expect(score).to be_within(0.001).of(25.0)
        end

        it 'should return 25 if metadata contains a graph which has classes' do
          metadata = {GRAPH: {classes: ['CLASS1', 'CLASS2'], labels: [], properties: [], datatypes: []}}

          score = target.score_metadata(metadata)

          expect(score).to be_within(0.001).of(25.0)
        end

        it 'should return 25 if metadata contains a graph which has a label' do
          metadata = {GRAPH: {classes: [], labels: ['LABEL'], properties: [], datatypes: []}}

          score = target.score_metadata(metadata)

          expect(score).to be_within(0.001).of(25.0)
        end

        it 'should return 25 if metadata contains a graph which has a property' do
          metadata = {GRAPH: {classes: [], labels: [], properties: ['PROPERTY1'], datatypes: []}}

          score = target.score_metadata(metadata)

          expect(score).to be_within(0.001).of(25.0)
        end

        it 'should return 25 if metadata contains a graph which has a datatype' do
          metadata = {GRAPH: {classes: [], labels: [], properties: [], datatypes: ['DATATYPE1']}}

          score = target.score_metadata(metadata)

          expect(score).to be_within(0.001).of(25.0)
        end

        it 'should return 50 if metadata contains a graph which has classes and datatypes' do
          metadata = {GRAPH: {classes: ['CLASS1'], labels: [], properties: [], datatypes: ['DATATYPE1']}}

          score = target.score_metadata(metadata)

          expect(score).to be_within(0.001).of(50.0)
        end

        it 'should return 50 if metadata contains a graph which has all elements' do
          metadata = {GRAPH: {classes: ['CLASS1'], labels: ['LABEL1'], properties: ['PROPERTY1'], datatypes: ['DATATYPE1']}}

          score = target.score_metadata(metadata)

          expect(score).to be_within(0.001).of(100.0)
        end

        it 'should return 67.5 if metadata contains a graph scored as 100 and a graph scored as 25' do
          metadata = {GRAPH1: {classes: ['CLASS1'], labels: ['LABEL1'], properties: ['PROPERTY1'], datatypes: ['DATATYPE1']},
                      GRAPH2: {classes: ['CLASS1'], labels: [], properties: [], datatypes: []}}

          score = target.score_metadata(metadata)

          expect(score).to be_within(0.001).of(62.5)
        end

      end

    end
  end
end
