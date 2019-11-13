require 'active_support'
require 'active_support/core_ext'
require 'csv'
require 'thor'

module Umakadata
  module Tasks
    class DatasetRelation < Thor
      namespace 'admin dataset_relation'

      desc 'add <Endpoint> <Source> <Destination>', <<~DESC
        Add dataset relation:
          each arguments are endpoint ID or name (exact match)
          this command allows reading from standard input (CSV or TSV)

          Example CSV (4th column is optional):
            1,2,3,sameAs
            [endpoint name],[another endpoint name],[the other endpoint name],seeAlso
      DESC
      method_option :pretty, type: :boolean, default: false, aliases: '-p', desc: 'Print pretty json'
      method_option :relation, type: :string, aliases: '-r', desc: 'Optional (e.g. sameAs, seeAlso, ...)'

      if STDIN.tty?
        def add(endpoint, src_endpoint, dst_endpoint)
          setup

          relation = add_relation(endpoint, src_endpoint, dst_endpoint, options[:relation])

          print relation.attributes
        rescue => e
          say e.message
          exit(1)
        end
      else
        def add
          say 'Reading from standard input...'

          setup

          buf = []
          ActiveRecord::Base.transaction do
            rows.each do |row|
              next if row.size < 3

              buf << add_relation(*row)
            end
          end

          print buf.map(&:attributes)
        rescue => e
          say e.message
          exit(1)
        end
      end

      desc 'list', 'List dataset relations'
      method_option :pretty, type: :boolean, default: false, aliases: '-p', desc: 'Print pretty json'
      method_option :endpoint, type: :numeric, aliases: '-e', desc: 'Endpoint ID or name (exact match)'
      method_option :src_endpoint, type: :numeric, aliases: '-s', desc: 'Source endpoint ID or name (exact match)'
      method_option :dst_endpoint, type: :numeric, aliases: '-d', desc: 'Destination endpoint ID or name (exact match)'

      def list
        setup

        relations = lookup_dataset_relations
        hash = relations.map(&:attributes)

        print hash
      end

      desc 'remove', 'Remove dataset relations'
      method_option :pretty, type: :boolean, default: false, aliases: '-p', desc: 'Print pretty json'
      method_option :force, type: :boolean, default: false, aliases: '-f', desc: 'Remove without prompt'
      method_option :endpoint, type: :numeric, aliases: '-e', desc: 'Endpoint ID or name (exact match)'
      method_option :src_endpoint, type: :numeric, aliases: '-s', desc: 'Source endpoint ID or name (exact match)'
      method_option :dst_endpoint, type: :numeric, aliases: '-d', desc: 'Destination endpoint ID or name (exact match)'

      def remove
        setup

        relations = lookup_dataset_relations
        hash = relations.map(&:attributes)

        if hash.size.zero?
          say 'No relations found.'
          return
        end

        say "Remove following #{hash.size} #{'relation'.pluralize(hash.size)}"
        print hash

        if options[:force] || yes?('Are you sure? [y/N]:')
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

      def lookup_dataset_relations
        relations = ::DatasetRelation.all

        if options[:endpoint]
          endpoint = lookup_endpoint(options[:endpoint])
          relations = relations.where(endpoint_id: endpoint.id)
        end
        if options[:src_endpoint]
          src_endpoint = lookup_endpoint(options[:src_endpoint])
          relations = relations.where(endpoint_id: src_endpoint.id)
        end
        if options[:dst_endpoint]
          dst_endpoint = lookup_endpoint(options[:dst_endpoint])
          relations = relations.where(endpoint_id: dst_endpoint.id)
        end

        relations
      end

      def add_relation(endpoint, src_endpoint, dst_endpoint, relation = nil)
        endpoint = lookup_endpoint(endpoint)
        src_endpoint = lookup_endpoint(src_endpoint)
        dst_endpoint = lookup_endpoint(dst_endpoint)

        ::DatasetRelation.create! do |r|
          r.endpoint_id = endpoint.id
          r.src_endpoint_id = src_endpoint.id
          r.dst_endpoint_id = dst_endpoint.id
          r.relation = relation if relation.present?
        end
      end

      def rows
        input = STDIN.readlines

        sep = if (3..4).include?(input.first.split("\t").size)
                "\t"
              elsif (3..4).include?(input.first.split(',').size)
                ','
              else
                raise 'Failed to detect separator.'
              end

        CSV.new(input.join, col_sep: sep)
      end
    end
  end
end
