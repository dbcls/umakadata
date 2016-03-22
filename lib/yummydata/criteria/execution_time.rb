require 'yummydata/http_helper'
require 'sparql/client'
require 'rdf/turtle'

module Yummydata
  module Criteria
    module ExecutionTime

      REGEXP = /<title>(.*)<\/title>/

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
        target_response_time = self.response_time(TARGET_QUERY)
        if base_response_time.nil? || target_response_time.nil?
          return nil
        end

        execution_time = target_response_time - base_response_time
        return execution_time < 0.0 ? nil : execution_time
      end

      def response_time(sparql_query)
        start_time = Time.now

        begin
          result = @client.query(sparql_query)
          if result.nil?
            @client.response(sparql_query)
            set_error('Endpoint URI is different from actual URI in executing query')
            return nil
          end
        rescue SPARQL::Client::MalformedQuery => e
          set_error("Query: #{sparql_query}, Error: #{e.message}")
          return nil
        rescue SPARQL::Client::ClientError, SPARQL::Client::ServerError => e
          message = e.message.scan(REGEXP)[0]
          set_error("Query: #{sparql_query}, Error: #{message.nil? ? '' : message[0]}")
          return nil

        rescue => e
          set_error("Query: #{sparql_query}, Error: #{e.to_s}")
          return nil
        end
        end_time = Time.now
        
        end_time - start_time
      end

    end
  end
end
