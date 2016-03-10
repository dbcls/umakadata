require 'sparql/client'

module Yummydata
  module Criteria
    class BasicSPARQL

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
        rescue
          return nil
        end
      end

    end
  end
end
