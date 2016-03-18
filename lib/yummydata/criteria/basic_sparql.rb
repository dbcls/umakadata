require 'sparql/client'
require 'yummydata/error_helper'

module Yummydata
  module Criteria
    class BasicSPARQL

      include Yummydata::ErrorHelper

      def initialize(uri)
        @client = SPARQL::Client.new(uri)
      end

      def count_statements
        result = query("SELECT COUNT(*) AS ?c WHERE {?s ?p ?o}")
        return nil if result.nil?
        return result[0][:c]
      end

      def nth_statement(offset)
        result = query("SELECT * WHERE {?s ?p ?o} OFFSET #{offset} LIMIT 1")
        return nil if result.nil? || result[0].nil?
        return [ result[0][:s], result[0][:p], result[0][:o] ]
      end

      def query(query)
        begin
          return @client.query(query)
        rescue => e
          set_error(e.to_s)
          return nil
        end
      end

    end
  end
end
