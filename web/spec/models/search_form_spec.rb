require 'rails_helper'

RSpec.describe SearchForm, type: :model do

  describe '#search' do
    before do
      @endpoint1 = FactoryBot.create(:endpoint, id: 1, name: 'Endpoint 1', url: 'http://www.example.com/sparql')
      create(:evaluation, endpoint_id: 1, retrieved_at: DateTime.parse('2018-08-01'),
                        score: 80, alive_rate: 0.5, rank: 5, cool_uri_rate: 55,
                        ontology_score: 45, metadata_score: 62)
      create(:prefix, endpoint_id: 1, allow_regex: 'http://purl.example.com/')
    end

    context 'by name' do
      it 'should return endpoint if name matches' do
        expect(SearchForm.new(name: 'Endpoint').search.to_a).to eq([@endpoint1])
      end

      it 'should return no endpoint if name does not match' do
        expect(SearchForm.new(name: 'Invalid Name').search.to_a).to eq([])
      end
    end

    context 'by prefix' do
      it 'should return endpoint if name matches' do
        expect(SearchForm.new(prefix: 'http://purl.example.com/').search.to_a).to eq([@endpoint1])
      end

      it 'should return no endpoint if name does not match' do
        expect(SearchForm.new(prefix: 'Invalid Prefix').search.to_a).to eq([])
      end
    end

    context 'by date' do
      it 'should return endpoint if date matches' do
        expect(SearchForm.new(date: '2018-08-01').search.to_a).to eq([@endpoint1])
      end

      it 'should return no endpoint if date does not match' do
        expect(SearchForm.new(date: '2018-08-11').search.to_a).to eq([])
      end
    end

    context 'by score' do
      it 'should return endpoint if score matches' do
        expect(SearchForm.new(score_lower: 70, score_upper: 90).search.to_a).to eq([@endpoint1])
      end

      it 'should return no endpoint if score_lower is too high' do
        expect(SearchForm.new(score_lower: 90).search.to_a).to eq([])
      end

      it 'should return no endpoint if score_upper is too low' do
        expect(SearchForm.new(score_upper: 70).search.to_a).to eq([])
      end
    end

    context 'by alive_rate' do
      it 'should return endpoint if alive_rate matches' do
        expect(SearchForm.new(alive_rate_lower: 0.4, alive_rate_upper: 0.6).search.to_a).to eq([@endpoint1])
      end

      it 'should return no endpoint if alive_rate_lower is too high' do
        expect(SearchForm.new(alive_rate_lower: 0.7).search.to_a).to eq([])
      end

      it 'should return no endpoint if alive_rate_upper is too low' do
        expect(SearchForm.new(alive_rate_upper: 0.3).search.to_a).to eq([])
      end
    end

    context 'by rank' do
      it 'should return endpoint if rank matches' do
        expect(SearchForm.new(rank: 'A').search.to_a).to eq([@endpoint1])
      end

      it 'should return no endpoint if rank does not match' do
        expect(SearchForm.new(rank: 'B').search.to_a).to eq([])
      end
    end

    context 'by cool_uri_rate' do
      it 'should return endpoint if cool_uri_rate matches' do
        expect(SearchForm.new(cool_uri_rate_lower: 50, cool_uri_rate_upper: 60).search.to_a).to eq([@endpoint1])
      end

      it 'should return no endpoint if cool_uri_rate_lower is too high' do
        expect(SearchForm.new(cool_uri_rate_lower: 60).search.to_a).to eq([])
      end

      it 'should return no endpoint if cool_uri_rate_upper is too low' do
        expect(SearchForm.new(cool_uri_rate_upper: 50).search.to_a).to eq([])
      end
    end

    context 'by ontology' do
      it 'should return endpoint if ontology matches' do
        expect(SearchForm.new(ontology_lower: 40, ontology_upper: 50).search.to_a).to eq([@endpoint1])
      end

      it 'should return no endpoint if ontology_lower is too high' do
        expect(SearchForm.new(ontology_lower: 60).search.to_a).to eq([])
      end

      it 'should return no endpoint if ontology_upper is too low' do
        expect(SearchForm.new(ontology_upper: 40).search.to_a).to eq([])
      end
    end

    context 'by metadata' do
      it 'should return endpoint if metadata matches' do
        expect(SearchForm.new(metadata_lower: 60, metadata_upper: 65).search.to_a).to eq([@endpoint1])
      end

      it 'should return no endpoint if  metadata_lower is too high' do
        expect(SearchForm.new(metadata_lower: 70).search.to_a).to eq([])
      end

      it 'should return no endpoint if ontology_upper is too low' do
        expect(SearchForm.new(metadata_upper: 60).search.to_a).to eq([])
      end
    end

    context 'by prefix_filter' do
      before(:context) do
        PrefixFilter.create(endpoint_id: 1, element_type: 'subject', uri: 'http://filter.example.jp')
      end

      before do
        allow(Umakadata::SparqlHelper).to receive(:query).and_return(['nonempty array'])
      end

      it 'should return endpoint if prefix_filter matches' do
        expect(SearchForm.new(element_type: 'subject', prefix_filter_uri: 'http://filter.example.jp').search.to_a).to eq([@endpoint1])
      end

      it 'should return endpoint if element_type does not match' do
        expect(SearchForm.new(element_type: 'subject', prefix_filter_uri: 'http://filter.example.jp').search.to_a).to eq([@endpoint1])
      end

      it 'should return endpoint if prefix_filter matches' do
        expect(SearchForm.new(element_type: 'subject', prefix_filter_uri: 'http://filter.example.jp').search.to_a).to eq([@endpoint1])
      end
    end

    context 'by boolean conditions' do
      before do
        @endpoint2 = FactoryBot.create(:endpoint, id: 2, name: 'Endpoint 2', url: 'http://www.example2.com/sparql')
        FactoryBot.create(:evaluation, endpoint_id: 2,
                          service_description: 'not empty',
                          void_ttl: 'not empty',
                          support_content_negotiation: true,
                          support_html_format: true,
                          support_turtle_format: true,
                          support_xml_format: true)
      end

      it 'should return all endpoints if no condition is specified' do
        expect(SearchForm.new().search.to_a).to eq([@endpoint1, @endpoint2])
      end

      context 'by service_description' do
        it 'should return only endpoint2 if service_description is specified' do
          expect(SearchForm.new(service_description: 'true').search.to_a).to eq([@endpoint2])
        end
      end

      context 'by void' do
        it 'should return only endpoint2 if void is specified' do
          expect(SearchForm.new(void: 'true').search.to_a).to eq([@endpoint2])
        end
      end

      context 'by content_negotiation' do
        it 'should return only endpoint2 if content_negotiation is specified' do
          expect(SearchForm.new(content_negotiation: 'true').search.to_a).to eq([@endpoint2])
        end
      end

      context 'by html' do
        it 'should return only endpoint2 if html is specified' do
          expect(SearchForm.new(html: 'true').search.to_a).to eq([@endpoint2])
        end
      end

      context 'by turtle' do
        it 'should return only endpoint2 if content_negotiation is supported' do
          expect(SearchForm.new(turtle: 'true').search.to_a).to eq([@endpoint2])
        end
      end

      context 'by xml_format' do
        it 'should return only endpoint2 if content_negotiation is supported' do
          expect(SearchForm.new(xml: 'true').search.to_a).to eq([@endpoint2])
        end
      end
    end
  end
end