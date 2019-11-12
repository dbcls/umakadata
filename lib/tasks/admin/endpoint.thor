require 'thor'

module Umakadata
  module Tasks
    class Endpoint < Thor
      desc 'list', 'list endpoints'
      method_option :pretty, type: :boolean, default: false, aliases: '-p', desc: 'print pretty json'
      method_option :disabled, type: :boolean, default: false, desc: 'include disabled endpoints'

      def list
        setup

        endpoints = options[:disabled] ? ::Endpoint.all : ::Endpoint.active

        hash = endpoints.map(&:attributes)

        print(hash)
      end

      desc 'search <keyword>', 'search endpoint'
      method_option :pretty, type: :boolean, default: false, aliases: '-p', desc: 'print pretty json'
      method_option :disabled, type: :boolean, default: false, desc: 'include disabled endpoints'

      def search(keyword)
        setup

        endpoints = options[:disabled] ? ::Endpoint.all : ::Endpoint.active

        endpoints = endpoints.merge(::Endpoint
                                      .where('"endpoints"."name" ILIKE ?', "%#{keyword.downcase}%")
                                      .or(::Endpoint.where('"endpoints"."endpoint_url" ILIKE ?', "%#{keyword.downcase}%")))

        hash = endpoints.map(&:attributes)

        print(hash)
      end

      private

      def setup
        require_relative '../../../config/application'
        Rails.application.initialize!
      end

      def print(hash)
        if options[:pretty]
          puts JSON.pretty_generate(hash)
        else
          puts hash.to_json
        end
      end
    end
  end
end
