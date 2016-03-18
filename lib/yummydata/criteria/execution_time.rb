require 'yummydata/http_helper'
require 'sparql/client'
require 'rdf/turtle'

module Yummydata
  module Criteria
    module ExecutionTime

      include Yummydata::ErrorHelper

      BASE_QUERY = <<-'SPARQL'
ASK{}
SPARQL

      TARGET_QUERY = <<-'SPARQL'
SELECT DISTINCT
  ?g
WHERE {
  GRAPH ?g {
    ?s ?p ?o
  }
}
SPARQL

      def prepare(uri)
        @client = SPARQL::Client.new(uri, {'read_timeout': 5 * 60}) if @uri == uri && @client == nil
        @uri = uri
      end

      def set_client(client)
        @client = client
      end

      def execution_time(uri)
        self.prepare(uri)

        base_response_time = self.response_time(BASE_QUERY)
        if base_response_time.nil?
          set_error("failure in ask query")
          return nil
        end

        target_response_time = self.response_time(TARGET_QUERY)
        if target_response_time.nil?
          set_error("failure in select query")
          return nil
        end

        execution_time = target_response_time - base_response_time
        if execution_time < 0.0
          set_error("execution time is invalid")
          return nil
        end

        execution_time
      end

      def response_time(sparql_query)
        begin
          start_time = Time.now

          result = @client.query(sparql_query)
          return nil if result.nil?

          end_time = Time.now
        rescue => e
          set_error(e.to_s)
          return nil
        end

        end_time - start_time
      end

    end
  end
end
