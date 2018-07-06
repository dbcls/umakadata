require 'rails_helper'
require 'sawyer'

RSpec.describe Endpoint, type: :model do

  let(:target) { Endpoint.new(id: 1, name: 'Endpoint 1', issue_id: 1) }

  describe '::create_issue' do

    it 'should return false if GithubHelper.create_issue() is failed' do
      allow(GithubHelper).to receive(:create_issue).and_return(nil)
      expect(Endpoint.create_issue(target)).to eq(false)
    end

    it 'should return false if GithubHelper.add_label() is failed' do
      issue = double(Sawyer::Resource, :number => 1)

      allow(GithubHelper).to receive(:create_issue).and_return(issue)
      allow(GithubHelper).to receive(:add_label).and_return(nil)

      expect(Endpoint.create_issue(target)).to eq(false)
    end

    it 'should return false if GithubHelper.add_labels_to_an_issue is failed' do
      issue   = double(Sawyer::Resource, :number => 1)
      label   = double(Sawyer::Resource, :name => 'Label name 1')
      results = double([double(Sawyer::Resource)])

      allow(GithubHelper).to receive(:create_issue).and_return(issue)
      allow(GithubHelper).to receive(:add_label).and_return(label)
      allow(GithubHelper).to receive(:add_labels_to_an_issue).and_return(nil)

      expect(Endpoint.create_issue(target)).to eq(false)
    end

    it 'should return true if Endpoint.create_issue() is Success' do
      issue   = double(Sawyer::Resource, :number => 1)
      label   = double(Sawyer::Resource, :name => 'Label name 1')
      results = double([double(Sawyer::Resource)])

      allow(GithubHelper).to receive(:create_issue).and_return(issue)
      allow(GithubHelper).to receive(:add_label).and_return(label)
      allow(GithubHelper).to receive(:add_labels_to_an_issue).and_return(results)

      expect(Endpoint.create_issue(target)).to eq(true)
    end
  end

  describe '::edit_issue' do

  end
end
