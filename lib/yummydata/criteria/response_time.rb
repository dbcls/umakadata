require 'yummydata/http_helper'
require 'sparql/client'
require 'rdf/turtle'

module Yummydata
  module Criteria
    module ResponseTime

      # include Yummydata::HTTPHelper

      def prepare(uri)
        @client = SPARQL::Client.new(uri, {'read_timeout': 5 * 60}) if @uri == uri && @client == nil
        @uri = uri
      end

      def execution_time(uri)
        self.prepare(uri)

        ask_query = <<-'SPARQL'
ASK{}
SPARQL
        ask_execution_time = self.response_time(ask_query)

        target_query = <<-'SPARQL'
SELECT DISTINCT
  ?g
WHERE {
  GRAPH ?g {
    ?s ?p ?o
  }
}
SPARQL

        tarresponse_time = self.response_time(target_query)
        if ask_execution_time.nil? || tarresponse_time.nil?
          return nil
        end

        execution_time = tarresponse_time - ask_execution_time
        execution_time >= 0.0 ? execution_time : nil
      end

      def response_time(sparql_query)
        begin
          start_time = Time.now

          result = @client.query(sparql_query)

          end_time = Time.now
        rescue => e
          return nil
        end

        return nil if result.nil?

        end_time - start_time
      end

    end
  end
end
