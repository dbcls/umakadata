require 'rdf/turtle'
require 'rdf/rdfxml'

module Yummydata
  module DataFormat

    UNKNOWN = 'unknown'
    TURTLE = 'text/turtle'.freeze
    RDFXML = 'application/rdf+xml'.freeze
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
        str = str.gsub(/@prefix\s*:\s*?<#>\s*\.\n/, '')
        str = str.gsub(/<>/, '<http://blank>')
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

      data = []
      reader.each_triple do |subject, predicate, object|
        data.push [subject, predicate, object]
      end
      return data
    end

  end
end
