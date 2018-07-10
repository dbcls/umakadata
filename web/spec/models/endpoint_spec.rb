require 'rails_helper'
require 'sawyer'

include FactoryBot::Syntax::Methods

RSpec.describe Endpoint, type: :model do

  after do
    FactoryBot.reload
  end

  describe '::create_issue' do

    it 'should return false if issue already exists' do
      endpoint = Endpoint.create(:name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      allow(GithubHelper).to receive(:create_issue).and_return(nil)
      expect(Endpoint.create_issue(endpoint)).to eq(false)
    end

    it 'should return false if label already exists' do
      endpoint = Endpoint.create(:name => 'Endpoint 1', :url => 'http://www.example.com/sparql')
      issue    = double(Sawyer::Resource)

      allow(issue).to receive(:[]).with(:number).and_return(1)
      allow(GithubHelper).to receive(:create_issue).and_return(issue)
      allow(GithubHelper).to receive(:add_label).and_return(nil)

      expect(Endpoint.create_issue(endpoint)).to eq(false)
    end

    it 'should return true if issue and label do not yet exist' do
      endpoint = Endpoint.create(:name => 'Endpoint 1', :url => 'http://www.example.com/sparql')
      issue    = double(Sawyer::Resource)
      label    = double(Sawyer::Resource)
      results  = double([double(Sawyer::Resource)])

      allow(issue).to receive(:[]).with(:number).and_return(1)
      allow(label).to receive(:[]).with(:name).and_return('Endpoint 1')
      allow(label).to receive(:[]).with(:id).and_return(1)
      allow(GithubHelper).to receive(:create_issue).and_return(issue)
      allow(GithubHelper).to receive(:add_label).and_return(label)
      allow(GithubHelper).to receive(:add_labels_to_an_issue).and_return(results)

      expect(Endpoint.create_issue(endpoint)).to eq(true)
    end
  end

  describe '::edit_issue' do

  end
end
