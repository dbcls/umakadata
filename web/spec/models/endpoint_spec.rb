require 'rails_helper'
require 'sawyer'

include FactoryBot::Syntax::Methods

RSpec.describe Endpoint, type: :model do

  after do
    FactoryBot.reload
  end

  describe '::create_label' do
    it 'should raise exception if label already exists' do
      endpoint = Endpoint.new(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      allow(GithubHelper).to receive(:add_label).and_raise(Octokit::UnprocessableEntity)

      expect { Endpoint.create_label(endpoint) }.to raise_exception(Octokit::UnprocessableEntity)
    end

    it 'should return the trimmed label if label name is too long (maximum is 50 character)' do
      endpoint = Endpoint.new(:id => 1, :name => 'Microbial Genome Database for Comparative Analysis (MBGD)', :url => 'http://www.example.com/sparql')
      label    = double(Sawyer::Resource)

      allow(label).to receive(:[]).with(:id).and_return(1)
      allow(GithubHelper).to receive(:add_label).with('Microbial Genome Database for Comparative Analysis', anything).and_return(label)
      allow(endpoint).to receive(:update_column).and_return(nil)

      expect(Endpoint.create_label(endpoint)).to eq(label)
    end

    it 'should return label if label does not yet exist' do
      endpoint = Endpoint.new(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql')
      label    = double(Sawyer::Resource)

      allow(label).to receive(:[]).with(:id).and_return(1)
      allow(GithubHelper).to receive(:add_label).with(endpoint.name, anything).and_return(label)
      allow(endpoint).to receive(:update_column).and_return(nil)

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
      endpoint = Endpoint.new(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      issue = double(Sawyer::Resource)

      allow(issue).to receive(:[]).with(:number).and_return(1)
      allow(issue).to receive(:is_a?).with(Sawyer::Resource).and_return(true)
      allow(endpoint).to receive(:update_column).and_return(nil)
      allow(GithubHelper).to receive(:issue_exists?).and_return(false)
      allow(GithubHelper).to receive(:create_issue).and_return(issue)

      expect(Endpoint.create_issue(endpoint)).to eq(issue)
    end

  end

  describe '::edit_issue' do
    it 'should raise exception if endpoint.issue_id does not exist' do
      endpoint = Endpoint.new(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      allow(GithubHelper).to receive(:labels_for_issue).and_raise(Octokit::UnprocessableEntity)

      expect { Endpoint.edit_issue(endpoint) }.to raise_exception(Octokit::UnprocessableEntity)
    end

    it 'should raise exception if GithubHelper.labels_for_issue() returns []' do
      endpoint = Endpoint.new(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql')

      allow(GithubHelper).to receive(:labels_for_issue).and_return([])

      expect { Endpoint.edit_issue(endpoint) }.to raise_exception("issue for #{endpoint.name} does not have a label")
    end

    it 'should raise exception if GithubHelper.edit_issue() raise exception' do
      endpoint = Endpoint.new(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql', :label_id => 1)

      label = double(Sawyer::Resource)

      allow(label).to receive(:[]).with(:id).and_return(1)
      allow(label).to receive(:[]).with(:name).and_return('Endpoint 1')

      allow(GithubHelper).to receive(:labels_for_issue).and_return([label])
      allow(GithubHelper).to receive(:update_label).and_return(nil)
      allow(GithubHelper).to receive(:edit_issue).and_raise(Octokit::UnprocessableEntity)

      expect { Endpoint.edit_issue(endpoint) }.to raise_exception(Octokit::UnprocessableEntity)
    end

    it 'is Success if endpoint.name is too long (maximum is 50 characters)' do
      endpoint = Endpoint.new(:id => 1, :name => 'Microbial Genome Database for Comparative Analysis (MBGD)', :url => 'http://www.example.com/sparql', :label_id => 1)
      label    = double(Sawyer::Resource)

      allow(label).to receive(:[]).with(:id).and_return(1)
      allow(label).to receive(:[]).with(:name).and_return('Endpoint 1')

      allow(GithubHelper).to receive(:labels_for_issue).and_return([label])
      allow(GithubHelper).to receive(:update_label).with(anything, { :name => 'Microbial Genome Database for Comparative Analysis' }).and_return(true)
      allow(GithubHelper).to receive(:edit_issue).and_return(true)

      expect { Endpoint.edit_issue(endpoint) }.not_to raise_exception
    end

    it 'is Success if there is no problem for endpoint' do
      endpoint = Endpoint.new(:id => 1, :name => 'Endpoint 1', :url => 'http://www.example.com/sparql', :label_id => 1)
      label    = double(Sawyer::Resource)

      allow(label).to receive(:[]).with(:id).and_return(1)
      allow(label).to receive(:[]).with(:name).and_return('Endpoint 1')

      allow(GithubHelper).to receive(:labels_for_issue).and_return([label])
      allow(GithubHelper).to receive(:update_label).and_return(true)
      allow(GithubHelper).to receive(:edit_issue).and_return(true)

      expect { Endpoint.edit_issue(endpoint) }.not_to raise_exception
    end
  end
end
