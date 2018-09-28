require 'rails_helper'
require 'sawyer'

RSpec.describe Endpoint, type: :model do

  after do
    FactoryBot.reload
  end

  describe '::create_label' do
    it 'should return existing label if label already exists' do
      endpoint = Endpoint.create(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql')
      label = double(Sawyer::Resource)

      allow(label).to receive(:[]).with(:id).and_return(1)
      allow(GithubHelper).to receive(:label_exists?).and_return(true)
      allow(GithubHelper).to receive(:get_label).and_return(label)

      expect(Endpoint.create_label(endpoint) ).to eq(label)
    end

    it 'should return label if label does not yet exist' do
      endpoint = Endpoint.create(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql')
      label    = double(Sawyer::Resource)

      allow(label).to receive(:[]).with(:id).and_return(1)
      allow(GithubHelper).to receive(:label_exists?).and_return(nil)
      allow(GithubHelper).to receive(:add_label).with(endpoint.id.to_s, anything).and_return(label)

      expect(Endpoint.create_label(endpoint)).to eq(label)
    end
  end

  describe '::create_issue' do
    it 'should raise exception if issue already exists' do
      endpoint = Endpoint.new(:name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      allow(GithubHelper).to receive(:issue_exists?).and_return(true)

      expect { Endpoint.create_issue(endpoint) }.to raise_exception(StandardError)
    end


    it 'should return issue if issue does not yet exist' do
      endpoint = Endpoint.create(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      issue = double(Sawyer::Resource)

      allow(issue).to receive(:[]).with(:number).and_return(1)
      allow(issue).to receive(:is_a?).with(Sawyer::Resource).and_return(true)
      allow(GithubHelper).to receive(:issue_exists?).and_return(false)
      allow(GithubHelper).to receive(:create_issue).and_return(issue)

      expect(Endpoint.create_issue(endpoint)).to eq(issue)
    end

  end

  describe '::sync_label' do
    it 'should raise exception if GithubHelper.labels_for_issue() raise exception' do
      endpoint = Endpoint.create(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      allow(GithubHelper).to receive(:labels_for_issue).and_raise(Octokit::UnprocessableEntity)

      expect { Endpoint.sync_label(endpoint) }.to raise_exception(Octokit::UnprocessableEntity)
    end

    it 'should raise exception if GithubHelper.labels_for_issue() returns []' do
      endpoint = Endpoint.create(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      allow(GithubHelper).to receive(:labels_for_issue).and_return([])

      expect { Endpoint.sync_label(endpoint) }.to raise_exception("issue for #{endpoint.name} does not have a label")
    end

    it 'is Success if there is no problem for endpoint' do
      endpoint = Endpoint.create(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql', :label_id => 1)
      label    = double(Sawyer::Resource)

      allow(label).to receive(:[]).with(:id).and_return(1)
      allow(label).to receive(:[]).with(:name).and_return('Endpoint 1')

      allow(GithubHelper).to receive(:labels_for_issue).and_return([label])
      allow(GithubHelper).to receive(:update_label).and_return(nil)

      expect { Endpoint.sync_label(endpoint) }.not_to raise_exception
    end
  end
end
