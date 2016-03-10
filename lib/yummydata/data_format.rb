require 'rdf/turtle'
require 'rdf/rdfxml'

module Yummydata
  module DataFormat

    UNKNOWN = 'unknown'
    TURTLE = 'text/turtle'.freeze
    RDFXML = 'rdf+xml'.freeze
    HTML   = 'text/html'.freeze

    def xml?(str)
      return !make_reader_for_xml(str).nil?
    end

    def ttl?(str)
      return !make_reader_for_ttl(str).nil?
    end

    def make_reader_for_xml(str)
      begin
        reader = RDF::RDFXML::Reader.new(str, {validate: true})
        return reader
      rescue
        return nil
      end
    end

    def make_reader_for_ttl(str)
      begin
        reader = RDF::Graph.new << RDF::Turtle::Reader.new(str, {validate: true})
        return reader
      rescue
        return nil
      end
    end

    def triples(str, type=nil)
      return nil if str.nil? || str.empty?

      reader = nil
      reader = make_reader_for_ttl(str) if type == TURTLE || (type.nil? && ttl?(str))
      reader = make_reader_for_xml(str) if type == RDFXML || (type.nil? && xml?(str))
      return nil if reader.nil?

      data = {}
      reader.each_triple do |subject, predicate, object|
        predicate_objects = data[subject]
        if predicate_objects.nil?
          predicate_objects = []
          data[subject] = predicate_objects
        end
        predicate_objects.push({ predicate => object })
      end
      data
    end

  end
end
