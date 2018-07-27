require 'spec_helper'
require 'rails_helper'

describe 'rake umakadata:*' do

  before(:all) do
    Rails.application.load_tasks
  end

  describe 'test_retriever_method' do
    before do
      Endpoint.create(:name => 'Endpoint 1', :url => 'http://example.com')
    end

    let(:task) { Rake::Task['umakadata:test_retriever_method'] }

    it 'should call Umakadata::Retriever#alive? if "alive?" is specified as method name' do
      allow_any_instance_of(Umakadata::Retriever).to receive(:alive?).and_return(true)
      arguments = Rake::TaskArguments.new(%i(name method_name),['Endpoint 1', 'alive?'])
      expect { task.execute(arguments) }.not_to raise_exception
    end

    it 'should call Umakadata::Retriever#check_content_negotiation with correct arguments' do
      retriever = double(Umakadata::Retriever)
      allow(retriever).to receive(:check_content_negotiation).with('text/html', anything).and_return(true)
      allow(Umakadata::Retriever).to receive(:new).and_return(retriever)
      arguments = Rake::TaskArguments.new(%i(name method_name),
                                          ['Endpoint 1', 'check_content_negotiation', 'text/html'])
      expect { task.execute(arguments) }.not_to raise_exception
    end
  end
end