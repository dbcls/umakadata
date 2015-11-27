require 'sparql/client'

module Yummydata

  class LinkedData

    def initialize(uri)
      @client = SPARQL::Client.new(uri)
    end

    def check
      {
        subject_is_uri:      !self.non_uri_subject?,
        subject_is_http_uri: !self.non_http_uri_subject?,
        uri_provides_info:    self.uri_provides_info?,
        contains_links:       self.contains_links?
      }
    end

    def non_uri_subject?
      sparql_query = <<-'SPARQL'
SELECT
  *
WHERE {
  GRAPH ?g { ?s ?p ?o } .
  filter (!isURI(?s))
}
LIMIT 1
SPARQL
      results = @client.query(sparql_query)
      results != nil && results.count > 0
    end

    def non_http_uri_subject?
      sparql_query = <<-'SPARQL'
SELECT
  *
WHERE {
  GRAPH ?g { ?s ?p ?o } .
  filter (!regex(?s, "http://", "i"))
}
LIMIT 1
SPARQL
      results = @client.query(sparql_query)
      results != nil && results.count > 0
    end

    def uri_provides_info?
      uri = self.get_subject_randomly
      if uri == nil
        return false
      end
      uri = URI(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      path = uri.path.empty? ? '/' : uri.path
      response = http.get(path, {})

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
      results = @client.query(sparql_query)
      if results != nil
        results[0][:s]
      else
        nil
      end
    end

    def contains_links?
      contains_same_as? || contains_see_also?
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
      results = @client.query(sparql_query)
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
      results = @client.query(sparql_query)
      results != nil && results.count > 0
    end

  end

end
