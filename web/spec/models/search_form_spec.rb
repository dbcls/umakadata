require 'rails_helper'

RSpec.describe SearchForm, type: :model do
  describe '#search' do

    before do
      @endpoints = [Endpoint.create(id: 1, name: 'Endpoint 1', url: 'http://www.example.com/sparql')]
      Evaluation.create(endpoint_id: 1)
      Prefixes.create(endpoint_id: 1,  allowed_uri: 'http://purl.example.com/')
    end

    context 'by name' do
      it 'should return endpoint if name matches' do
        expect(SearchForm.new(name: 'Endpoint').search.to_a).to eq(@endpoints)
      end

      it 'should return no endpoint if name does not match' do
        expect(SearchForm.new(name: 'Invalid Name').search.to_a).to eq([])
      end
    end

    context 'by prefix' do
      it 'should return endpoint if name matches' do
        expect(SearchForm.new(prefix: 'http://purl.example.com/').search.to_a).to eq(@endpoints)
      end

      it 'should return no endpoint if name does not match' do
        expect(SearchForm.new(prefix: 'Invalid Prefix').search.to_a).to eq([])
      end
    end
  end
end