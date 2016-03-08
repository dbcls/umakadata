require "yummydata/http_helper"
require "sparql/client"

module Yummydata
  module Criteria
    class Metadata

      def initialize(uri)
        @client = SPARQL::Client.new(uri, {'read_timeout': 5 * 60})
      end

      def score
        score_list = []
        graphs = self.list_of_graph_uris
        graphs.each do |graph|
          score_list.push(self.score_graph(graph))
        end
        return 0 if score_list.empty?
        return score_list.inject(0.0) { |r, i| r += i } / score_list.size
      end

      def score_graph(graph)
        score = 0
        classes = self.classes_on_graph(graph)
        score += 25 unless classes.empty?

        labels = self.list_of_labels_of_classes(graph, classes)
        score += 25 unless labels.empty?

        datatypes = self.list_of_datatypes(graph)
        score += 25 unless labels.empty?

        properties = self.list_of_properties_on_graph(graph)
        score += 25 unless properties.empty?

        return score
      end

      def classes_on_graph(graph)
        classes = []
        classes += self.list_of_classes_on_graph(graph)
        classes += self.list_of_classes_having_instances(graph)
        classes.uniq!
        return classes
      end

      def list_of_graph_uris
        query = <<-SPARQL
SELECT DISTINCT ?g
WHERE {
  GRAPH ?g
  { ?s ?p ?o.
    filter ( ?g NOT IN (<http://www.openlinksw.com/schemas/virtrdf#>) )
  }
}
SPARQL
        results = self.query_metadata(query)
        results.map { |solution| solution[:g] }
      end

      def list_of_classes_on_graph(graph)
        query = <<-SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT DISTINCT ?c
FROM <#{graph}>
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
        results = self.query_metadata(query)
        results.map { |solution| solution[:c] }
      end

      def list_of_classes_having_instances(graph)
        query = <<-SPARQL
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT DISTINCT ?c
FROM <#{graph}>
WHERE { [] rdf:type ?c. }
SPARQL
        results = self.query_metadata(query)
        results.map { |solution| solution[:c] }
      end

      def list_of_labels_of_a_class(graph, cls)
        query = <<-SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT DISTINCT ?label
FROM <#{graph}>
WHERE{ <#{cls}> rdfs:label ?label. }
SPARQL
        results = self.query_metadata(query)
        results.map { |solution| solution[:label] }
      end

      def list_of_labels_of_classes(graph, classes)
        query = <<-SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT DISTINCT ?c ?label
WHERE {
    graph <#{graph}> {
      ?c rdfs:label ?label.
      filter (
        ?c IN (<#{classes.join('>,<')}>)
      )
    }
}
SPARQL
        results = self.query_metadata(query)
        results.map { |solution| solution[:label] }
      end

      def number_of_instances_of_class_on_a_graph(graph, cls)
        query = <<-SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT (count(DISTINCT ?i)  AS ?num)
  FROM <#{graph}>
WHERE{
  { ?i rdf:type <#{cls}>. }
  UNION
  { [] ?p ?i. ?p rdfs:range <#{cls}>. }
  UNION
  { ?i ?p []. ?p rdfs:domain <#{cls}>. }
}
SPARQL
        results = self.query_metadata(query)
        return results[0][:num]
      end

      def list_of_properties_on_graph(graph)
        query = <<-SPARQL
SELECT DISTINCT ?p
        FROM <#{graph}>
WHERE{
        ?s ?p ?o.
}
SPARQL
        results = self.query_metadata(query)
        results.map { |solution| solution[:p] }
      end

      def list_of_domain_classes_of_property_on_graph(graph, property)
        query = <<-SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT DISTINCT ?d
FROM <#{graph}>
WHERE {
  <#{property}> rdfs:domain ?d.
}
SPARQL
        results = self.query_metadata(query)
        results.map { |solution| solution[:d] }
      end

      def list_of_range_classes_of_property_on_graph(graph, property)
        query = <<-SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT DISTINCT ?r
FROM <#{graph}>
WHERE{
  <#{property}> rdfs:range ?r.
}
SPARQL
        results = self.query_metadata(query)
        results.map { |solution| solution[:d] }
      end

      def list_of_class_class_relationships(graph, property)
        query = <<-SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT DISTINCT ?d ?r
FROM <#{graph}>
WHERE{
        ?i <#{property}> ?o.
        OPTIONAL{ ?i rdf:type ?d.}
        OPTIONAL{ ?o rdf:type ?r.}
}
SPARQL
        results = self.query_metadata(query)
        results.map { |solution| [ solution[:d], solution[:r] ] }
      end

      def list_of_class_datatype_relationships(graph, property)
        query = <<-SPARQL
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT DISTINCT ?d (datatype(?o) AS ?ldt)
FROM <#{graph}>
WHERE{
    ?i <#{property}> ?o.
    OPTIONAL{ ?i rdf:type ?d.}
    FILTER(isLiteral(?o))
}
SPARQL
        results = self.query_metadata(query)
        return nil if !results
        results.map { |solution| [ solution[:d], solution[:ldt] ] }
      end

      def number_of_elements1(graph, property, domain, range)
        query = <<-SPARQL
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT (count(?i) AS ?numTriples) (count(DISTINCT ?i) AS ?numDomIns) (count(DISTINCT ?o) AS ?numRanIns)
FROM <#{graph}>
WHERE {
  SELECT DISTINCT ?i ?o WHERE {
    ?i <#{property}> ?o.
    ?i rdf:type <#{domain}>.
    ?o rdf:type <#{range}>.
  }
}
SPARQL
        results = self.query_metadata(query)
        return [ results[0][:numTriples], results[0][:numDomIns], results[0][:numRanIns] ]
      end

      def number_of_elements2(graph, property, datatype)
        query = <<-SPARQL
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT (count(?i) AS ?numTriples) (count(DISTINCT ?i) AS ?numDomIns) (count(DISTINCT ?o) AS ?numRanIns)
        FROM <#{graph}>
WHERE{
  SELECT DISTINCT ?i ?o WHERE{
    ?i <#{property}> ?o.
    ?i rdf:type ?d.
    FILTER( datatype(?o) = <#{datatype}> )
  }
}
SPARQL
        results = self.query_metadata(query)
        return [ results[0][:numTriples], results[0][:numDomIns], results[0][:numRanIns] ]
      end

      def number_of_elements3(graph, property)
query = <<-SPARQL
SELECT (count(?i) AS ?numTriples) (count(DISTINCT ?i) AS ?numDomIns) (count(DISTINCT ?o) AS ?numRanIns)
FROM <#{graph}>
WHERE{
   ?i <#{property}> ?o.
}
SPARQL
        results = self.query_metadata(query)
        return [ results[0][:numTriples], results[0][:numDomIns], results[0][:numRanIns] ]
      end

      def number_of_elements4(graph, property)
        query = <<-SPARQL
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT (count(DISTINCT ?i) AS ?numDomIns) (count(?i) AS ?numTriplesWithDom)
FROM <#{graph}>
WHERE {
  SELECT DISTINCT ?i ?o
  WHERE{
    ?i <#{property}> ?o.
    ?i rdf:type ?d.
  }
}
SPARQL
        results = self.query_metadata(query)
        return [ results[0][:numDomIns], results[0][:numTriplesWithDom] ]
      end

      def number_of_elements5(graph, property)
        query = <<-SPARQL
PREFIX rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>
SELECT (count(DISTINCT ?o) AS ?numRanIns) (count(?o) AS ?numTriplesWithRan)
FROM <#{graph}>
WHERE {
  SELECT DISTINCT ?i ?o
  WHERE{
    ?i <#{property}> ?o.
    ?o rdf:type ?r.
  }
}
SPARQL
        results = self.query_metadata(query)
        return [ results[0][:numRanIns], results[0][:numTriplesWithRan] ]
      end

      def number_of_elements6(graph, property)
        query = <<-SPARQL
SELECT (count(DISTINCT ?o) AS ?numRanIns) (count(?o) AS ?numTriplesWithRan)
FROM <#{graph}>
WHERE {
  SELECT DISTINCT ?i ?o
  WHERE{
    ?i <#{property}> ?o.
    FILTER(isLiteral(?o))
  }
}
SPARQL
        results = self.query_metadata(query)
        return [ results[0][:numRanIns], results[0][:numTriplesWithRan] ]
      end

      def list_of_properties_domains_ranges(graph)
        query = <<-SPARQL
PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
SELECT ?p ?d ?r
        FROM <#{graph}>
WHERE{
  ?p rdfs:domain ?d.
  ?p rdfs:range ?r.
}
SPARQL
        results = self.query_metadata(query)
        results.map { |solution| [ solution[:p], solution[:d], solution[:r] ] }
      end

      def list_of_datatypes(graph)
        query = <<-SPARQL
SELECT DISTINCT (datatype(?o) AS ?ldt)
FROM <#{graph}>
WHERE{
  [] ?p ?o.
  FILTER(isLiteral(?o))
}
SPARQL
        results = self.query_metadata(query)
        return nil if !results
        results.map { |solution| solution[:ldt] }
      end

      def query_metadata(query)
        begin
          results = @client.query(query)
        rescue => e
          return false
        end
        return results
      end

    end
  end
end
