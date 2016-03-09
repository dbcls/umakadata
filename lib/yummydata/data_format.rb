require 'rdf/turtle'
require 'rdf/rdfxml'

module Yummydata
  module DataFormat

    TTL = 'ttl'.freeze    
    XML = 'xml'.freeze

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

    def parse(str, type=nil)
      reader = nil
      reader = make_reader_for_ttl(str) if type == TTL || (type.nil? && ttl?(str))
      reader = make_reader_for_xml(str) if type == XML || (type.nil? && xml?(str))
      return nil if reader.nil?

      data = {}
      reader.each_triple do |subject, predicate, object|
        data[predicate] = object
      end
      data
    end

  end
end
