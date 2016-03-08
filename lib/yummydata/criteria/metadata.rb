require "yummydata/http_helper"

module Yummydata
  module Criteria
    module Metadata

      def prepare(uri)
        @client = SPARQL::Client.new(uri, {'read_timeout': 5 * 60}) if @uri == uri && @client == nil
        @uri = uri
      end

      def list_of_graph_uris(uri)
        query = <<-'SPARQL'
SELECT DISTINCT ?g
WHERE {
  GRAPH ?g{ ?s ?p ?o.}
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def list_of_classes_on_graph(uri)
        query = <<-'SPARQL'
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT DISTINCT ?c
FROM <g>
WHERE {
  { ?c rdf:type rdfs:Class. }
  UNION
  { [] rdf:type ?c. }
  UNION
  { [] rdfs:domain ?c. }
  UNION
  { [] rdfs:range ?c. }
  UNION
  { ?c rdfs:subclassOf []. }
  UNION
  { [] rdfs:subclassOf ?c. }
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def list_of_classes_having_instances(uri)
        query = <<-'SPARQL'
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT DISTINCT ?c
FROM <g>
WHERE { [] rdf:type ?c. }
SPARQL
        return self.query_metadata(uri, query)
      end

      def list_of_labels_of_a_class(uri)
        query = <<-'SPARQL'
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT DISTINCT ?label
FROM <g>
WHERE{ <c> rdfs:label ?label. }
SPARQL
        return self.query_metadata(uri, query)
      end

      def list_of_labels_of_classes(uri)
        query = <<-'SPARQL'
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT DISTINCT ?c ?label
FROM <g>
WHERE{
  ?c rdfs:label ?label.
  ?c IN (c1, c2, ..., cn)
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def number_of_instances_of_class_on_a_graph(uri)
        query = <<-'SPARQL'
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT (count(DISTINCT ?i)  AS ?num)
  FROM <g>
WHERE{
  { ?i rdf:type <c>. }
  UNION
  { [] ?p ?i. ?p rdfs:range <c>. }
  UNION
  { ?i ?p []. ?p rdfs:domain <c>. }
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def list_of_domain_classes_of_property_on_graph1(uri)
        query = <<-'SPARQL'
SELECT DISTINCT ?p
        FROM <g>
WHERE{
        ?s ?p ?o.
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def list_of_domain_classes_of_property_on_graph2(uri)
        query = <<-'SPARQL'
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT DISTINCT ?d
FROM <g>
WHERE {
  <p> rdfs:domain ?d.
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def list_of_range_classes_of_property_on_graph(uri)
        query = <<-'SPARQL'
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT DISTINCT ?r
FROM <g>
WHERE{
　  <p> rdfs:range ?r.
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def list_of_class_class_relationships(uri)
        query = <<-'SPARQL'
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT DISTINCT ?d ?r
FROM <g>
WHERE{
        ?i <p> ?o.
        OPTIONAL{ ?i rdf:type ?d.}
        OPTIONAL{ ?o rdf:type ?r.}
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def list_of_class_datatype_relationships(uri)
        query = <<-'SPARQL'
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT DISTINCT ?d (datatype(?o) AS ?ldt)
FROM <g>
WHERE{
    ?i <p> ?o.
    OPTIONAL{ ?i rdf:type ?d.}
    FILTER(isLiteral(?o))
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def number_of_elements1(uri)
        query = <<-'SPARQL'
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT (count(?i) AS ?numTriples) (count(DISTINCT ?i) AS ?numDomIns) (count(DISTINCT ?o) AS ?numRanIns)
FROM <g>
WHERE{
　　SELECT DISTINCT ?i ?o WHERE{
        ?i <p> ?o.
        ?i rdf:type <d>.
        ?o rdf:type <r>.
    }
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def number_of_elements2(uri)
        query = <<-'SPARQL'
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT (count(?i) AS ?numTriples) (count(DISTINCT ?i) AS ?numDomIns) (count(DISTINCT ?o) AS ?numRanIns)
        FROM <g>
WHERE{
　　SELECT DISTINCT ?i ?o WHERE{
        ?i <p> ?o.
        ?i rdf:type ?d.
        FILTER( datatype(?o) = <idt>
    }
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def number_of_elements3(uri)
        query = <<-'SPARQL'
SELECT (count(?i) AS ?numTriples) (count(DISTINCT ?i) AS ?numDomIns) (count(DISTINCT ?o) AS ?numRanIns)
FROM <g>
WHERE{
   ?i <p> ?o.
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def number_of_elements4(uri)
        query = <<-'SPARQL'
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT (count(DISTINCT ?i) AS ?numDomIns) (count(?i) AS ?numTriplesWithDom)
FROM <g>
WHERE {
        SELECT DISTINCT ?i ?o
        WHERE{
                ?i <p> ?o.
                ?i rdf:type ?d.
        }
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def number_of_elements5(uri)
        query = <<-'SPARQL'
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT (count(DISTINCT ?o) AS ?numRanIns) (count(?o) AS ?numTriplesWithRan)
FROM <g>
WHERE {
        SELECT DISTINCT ?i ?o
        WHERE{
                ?i <p> ?o.
                ?o rdf:type ?r.
        }
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def number_of_elements6(uri)
        query = <<-'SPARQL'
SELECT (count(DISTINCT ?o) AS ?numRanIns) (count(?o) AS ?numTriplesWithRan)
FROM <g>
WHERE {
        SELECT DISTINCT ?i ?o
        WHERE{
                ?i <p> ?o.
                FILTER(isLiteral(?o))
        }
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def list_of_properties_domains_ranges(uri)
        query = <<-'SPARQL'
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT ?p ?d ?r
        FROM <g>
WHERE{
        ?p rdfs:domain ?d.
        ?p rdfs:range ?r.
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def list_of_datatypes(uri)
        query = <<-'SPARQL'
SELECT DISTINCT (datatype(?o) AS ?ldt)
FROM <g>
WHERE{
        [] ?p ?o.
        FILTER(isLiteral(?o))
}
SPARQL
        return self.query_metadata(uri, query)
      end

      def query_metadata(uri, query)
        prepare(uri)
        begin
          results = @client.query(query)
        rescue => e
          return false
        end
        return results != nil && results.count > 0
      end

    end
  end
end
