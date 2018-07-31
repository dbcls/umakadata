require 'rails_helper'

describe 'rake umakadata:*' do
  before(:all) do
    Rails.application.load_tasks
  end

  before do
    FactoryBot.create_list(:endpoint, 2)
  end

  describe 'test_retriever_method' do
    let(:task) { Rake::Task['umakadata:test_retriever_method'] }

    it 'should call Umakadata::Retriever#check_endpoint with correct arguments' do
      retriever = double(Umakadata::Retriever)
      allow(Umakadata::Retriever).to receive(:new).and_return(retriever)
      arguments = Rake::TaskArguments.new(%i(name method_name),
                                          ['Endpoint 1', 'check_endpoint', 'text/html'])
      expect(retriever).to receive(:check_endpoint).with('text/html', anything)
      task.execute(arguments)
    end
  end

  describe 'test_retriever_method_all' do
    let(:task) { Rake::Task['umakadata:test_retriever_method_all'] }

    it 'should call Umakadata::Retriever#check_content_negotiation with correct arguments' do
      retriever = double(Umakadata::Retriever)
      allow(retriever).to receive(:alive?).and_return(true)
      allow(Umakadata::Retriever).to receive(:new).and_return(retriever)
      arguments = Rake::TaskArguments.new(%i(method_name),
                                          ['check_content_negotiation', 'text/html'])
      expect(retriever).to receive(:check_content_negotiation).with('text/html', anything).twice
      task.execute(arguments)
    end
  end
end