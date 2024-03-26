require 'thor'

module Umakadata
  module Tasks
    class Db < Thor
      desc 'archive', 'archive old data'

      def archive
        initialize_app
        ArchiveJob.perform_inline
      end

      private

      def initialize_app
        require_relative '../../config/application'
        Rails.application.initialize!
      end
    end
  end
end
