require 'yummydata/http_helper'

module Yummydata
  module Criteria
    module LinkedDataRules

      include Yummydata::HTTPHelper

      def prepare(uri)
        @client = SPARQL::Client.new(uri, {'read_timeout': 5 * 60}) if @uri == uri && @client == nil
        @uri = uri
      end

      def uri_subject?(uri)
        self.prepare(uri)

        sparql_query = <<-'SPARQL'
SELECT
  *
WHERE {
GRAPH ?g { ?s ?p ?o } .
  filter (!isURI(?s) AND !isBLANK(?s) AND ?g NOT IN (
    <http://www.openlinksw.com/schemas/virtrdf#>
  ))
}
LIMIT 1
SPARQL

        begin
          results = @client.query(sparql_query)
        rescue => e
          return false
        end

        results != nil && results.count == 0
      end

      def http_subject?(uri)
        self.prepare(uri)

        sparql_query = <<-'SPARQL'
SELECT
  *
WHERE {
  GRAPH ?g { ?s ?p ?o } .
  filter (!regex(?s, "http://", "i") AND !isBLANK(?s) AND ?g NOT IN (
    <http://www.openlinksw.com/schemas/virtrdf#>
  ))
}
LIMIT 1
SPARQL

        begin
          results = @client.query(sparql_query)
          puts results
        rescue => e
          puts e
          return false
        end
        results != nil && results.count == 0
      end

      def uri_provides_info?(uri)
        self.prepare(uri)

        uri = self.get_subject_randomly()
        if uri == nil
          return false
        end
        begin
          response = http_get(URI(uri), {})
        rescue => e
          puts "INVALID URI: #{uri}"
          return false
        end

        response.is_a?(Net::HTTPSuccess) && !response.body.empty?
      end

      def get_subject_randomly
        sparql_query = <<-'SPARQL'
SELECT
  ?s
WHERE {
  GRAPH ?g { ?s ?p ?o } .
  filter (isURI(?s))
}
LIMIT 1
SPARQL
        begin
          results = @client.query(sparql_query)
        rescue => e
          return nil
        end
        if results != nil && results[0] != nil
          results[0][:s]
        else
          nil
        end
      end

      def contains_links?(uri)
        self.prepare(uri)

        self.contains_same_as?() || self.contains_see_also?()
      end

      def contains_same_as?
        sparql_query = <<-'SPARQL'
PREFIX owl:<http://www.w3.org/2002/07/owl#>
SELECT
  *
WHERE {
  GRAPH ?g { ?s owl:sameAs ?o } .
}
LIMIT 1
SPARQL
        begin
          results = @client.query(sparql_query)
        rescue => e
          return false
        end
        results != nil && results.count > 0
      end

      def contains_see_also?
        sparql_query = <<-'SPARQL'
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT
  *
WHERE {
  GRAPH ?g { ?s rdfs:seeAlso ?o } .
}
LIMIT 1
SPARQL
        begin
          results = @client.query(sparql_query)
        rescue => e
          return false
        end
        results != nil && results.count > 0
      end

    end
  end
end
