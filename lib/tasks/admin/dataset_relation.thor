require 'thor'

module Umakadata
  module Tasks
    class DatasetRelation < Thor
      desc 'add <Endpoint ID or name> <Source endpoint ID or name> <Destination endpoint ID or name>', 'add dataset relation'
      method_option :pretty, type: :boolean, default: false, aliases: '-p', desc: 'print pretty json'
      method_option :relation, type: :string, required: false, aliases: '-r', desc: 'specify relation'

      def add(endpoint, src_endpoint, dst_endpoint)
        setup

        endpoint = lookup_endpoint(endpoint)
        src_endpoint = lookup_endpoint(src_endpoint)
        dst_endpoint = lookup_endpoint(dst_endpoint)

        relation = ::DatasetRelation.create! do |r|
          r.endpoint_id = endpoint.id
          r.src_endpoint_id = src_endpoint.id
          r.dst_endpoint_id = dst_endpoint.id
        end

        print relation.attributes
      rescue => e
        say e.message
        exit(1)
      end

      desc 'list', 'list dataset relations'
      method_option :pretty, type: :boolean, default: false, aliases: '-p', desc: 'print pretty json'
      method_option :endpoint, type: :numeric, required: false, aliases: '-e', desc: 'specify endpoint id'
      method_option :src_endpoint, type: :numeric, required: false, aliases: '-s', desc: 'specify source endpoint id'
      method_option :dst_endpoint, type: :numeric, required: false, aliases: '-d', desc: 'specify destination endpoint id'

      def list
        setup

        relations = ::DatasetRelation.all
        relations = relations.where(endpoint_id: options[:endpoint]) if options[:endpoint]
        relations = relations.where(src_endpoint_id: options[:src_endpoint]) if options[:src_endpoint]
        relations = relations.where(dst_endpoint_id: options[:dst_endpoint]) if options[:dst_endpoint]

        hash = relations.map(&:attributes)

        print(hash)
      end

      desc 'remove', 'remove dataset relations'
      method_option :pretty, type: :boolean, default: false, aliases: '-p', desc: 'print pretty json'
      method_option :endpoint, type: :numeric, required: false, aliases: '-e', desc: 'specify endpoint id'
      method_option :src_endpoint, type: :numeric, required: false, aliases: '-s', desc: 'specify source endpoint id'
      method_option :dst_endpoint, type: :numeric, required: false, aliases: '-d', desc: 'specify destination endpoint id'

      def remove
        setup

        relations = ::DatasetRelation.all
        relations = relations.where(endpoint_id: options[:endpoint]) if options[:endpoint]
        relations = relations.where(src_endpoint_id: options[:src_endpoint]) if options[:src_endpoint]
        relations = relations.where(dst_endpoint_id: options[:dst_endpoint]) if options[:dst_endpoint]

        hash = relations.map(&:attributes)

        if hash.size.zero?
          say 'No relations found.'
          exit(2)
        end

        say "Remove following #{hash.size} #{'relation'.pluralize(hash.size)}"
        print(hash)

        if yes?('Are you sure? [y/N]:')
          relations.destroy_all
        else
          say('Abort.')
        end
      rescue => e
        say e.message
        exit(1)
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

      def lookup_endpoint(name_or_id)
        id = begin
          Integer(name_or_id)
        rescue
          ::Endpoint.find_by!(name: name_or_id).id
        end

        ::Endpoint.find(id)
      end
    end
  end
end
