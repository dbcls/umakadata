require 'sparql/client'

module Yummydata
  module Criteria
    module LastUpdate

      include Yummydata::Criteria::ServiceDescription
      include Yummydata::Criteria::VoID

      def prepare(uri)
        @client = SPARQL::Client.new(uri, {'read_timeout': 5 * 60}) if @uri == uri && @client == nil
        @uri = uri
      end

      def last_modified
          sd = service_description(@uri)
          return sd.modified unless sd.modified.nil?

          void = void_on_well_known_uri(@uri)
          return void.modified unless void.modified.nil?

          return nil
      end

      def count_statements(uri)
        self.prepare(uri)
        result = self.query(count_query)
        return nil if result.nil?
        return result
      end

      def first_statement(uri)
        self.prepare(uri)
        result = self.query(first_statement_query)
        return nil if result.nil?
        return result
      end

      def last_statement(uri, count)
        self.prepare(uri)
        offset = count - 1
        result = self.query(last_statement_query(offset))
        return nil if result.nil?
        return result
      end

      def count_query
        return "select count (*) AS ?c where {?s ?p ?o}"
      end

      def first_statement_query
        return "select * where {?s ?p ?o} LIMIT 1"
      end

      def offset_statement_query(offset)
        return "select * where {?s ?p ?o} OFFSET #{offset} LIMIT 1"
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
