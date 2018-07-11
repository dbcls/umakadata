require 'rails_helper'
require 'sawyer'

include FactoryBot::Syntax::Methods

RSpec.describe Endpoint, type: :model do

  after do
    FactoryBot.reload
  end

  describe '::create_issue' do
    it 'should return false if issue already exists' do
      endpoint = Endpoint.new(:name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      allow(GithubHelper).to receive(:issue_exists?).and_return(true)
      allow(GithubHelper).to receive(:label_exists?).and_return(false)
      expect { Endpoint.create_issue(endpoint) }.to raise_exception('issue for Endpoint 1 already exists')
    end

    it 'should return false if label already exists' do
      endpoint = Endpoint.new(:name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      allow(GithubHelper).to receive(:issue_exists?).and_return(false)
      allow(GithubHelper).to receive(:label_exists?).and_return(true)
      expect { Endpoint.create_issue(endpoint) }.to raise_exception('issue for Endpoint 1 already exists')
    end

    it 'should return true if issue and label do not yet exist' do
      endpoint = Endpoint.new(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      issue   = double(Sawyer::Resource)
      label   = double(Sawyer::Resource)
      results = double([double(Sawyer::Resource)])

      allow(endpoint).to receive(:update_column).and_return(nil)

      allow(label).to receive(:[]).with(:name).and_return('Endpoint 1')
      allow(label).to receive(:[]).with(:id).and_return(1)
      allow(label).to receive(:is_a?).with(Sawyer::Resource).and_return(true)

      allow(issue).to receive(:[]).with(:number).and_return(1)
      allow(issue).to receive(:is_a?).with(Sawyer::Resource).and_return(true)

      allow(GithubHelper).to receive(:issue_exists?).and_return(false)
      allow(GithubHelper).to receive(:label_exists?).and_return(false)
      allow(GithubHelper).to receive(:add_label).and_return(label)
      allow(GithubHelper).to receive(:create_issue).and_return(issue)
      allow(GithubHelper).to receive(:add_labels_to_an_issue).and_return(results)

      expect { Endpoint.create_issue(endpoint) }.not_to raise_exception
    end

    it 'should return false if endpoint.name is too long (maximum is 50 characters)' do
      endpoint = Endpoint.new(:id => 1, :name => 'Charles R. Drew University of Medicine and Science', :url => 'http://www.example.com/sparql')

      allow(GithubHelper).to receive(:issue_exists?).and_return(false)
      allow(GithubHelper).to receive(:label_exists?).and_return(false)
      allow(GithubHelper).to receive(:add_label).and_raise(Octokit::ClientError)

      expect { Endpoint.create_issue(endpoint) }.to raise_exception(Octokit::ClientError)
    end
  end

  describe '::edit_issue' do

  end
end
