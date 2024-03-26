require 'thor'

module Umakadata
  module Tasks
    class Admin < Thor
      Dir[File.expand_path('./lib/tasks/admin/*.thor')].each(&method(:load))

      desc 'endpoint', 'Commands for endpoint'
      subcommand 'endpoint', ::Umakadata::Tasks::Endpoint

      desc 'dataset_relation', 'Commands for dataset relation'
      subcommand 'dataset_relation', ::Umakadata::Tasks::DatasetRelation
    end
  end
end
