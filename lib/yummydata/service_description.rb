require 'rdf/turtle'
require 'rdf/rdfxml'
require 'yummydata/data_format'

module Yummydata

  class ServiceDescription

    include Yummydata::DataFormat

    ##
    # return the type of service description
    #
    # @return [String]
    attr_reader :type

    ##
    # return service description
    #
    # @return [String]
    attr_reader :text

    ##
    # return response headers
    #
    # @return [String]
    attr_reader :response_header

    ##
    # return modified
    #
    # @return [String]
    attr_reader :modified

    TYPE = {
      ttl: 'ttl',
      xml: 'xml',
      unknown: 'unknown'
    }.freeze

    def initialize(http_response)
      @type = TYPE[:unknown]
      @text = ''
      @response_header = ''
      @modified = ''

      if (!http_response.nil?)
        parse_body(http_response.body)

        http_response.each_key do |key|
          @response_header << key << ": " << http_response[key] << "\n"
        end
      end
    end

    private
    def parse_body(str)
      @text = str
      if xml?(str)
        @type = TYPE[:xml]
        data = parse_body_as_xml(str)
        @modified = data['dcterms:modified']
      elsif ttl?(str)
        @type = TYPE[:ttl]
        data = parse_body_as_ttl(str)
        @modified = data['dcterms:modified']
      else
        @type = TYPE[:unknown]
        @text = ''
        @modified = 'N/A'
      end
    end

    def parse_body_as_xml(str)
      data = {}
      reader = RDF::RDFXML::Reader.new(str, {validate: true})
      reader.each_triple do |subject, predicate, object|
        data[predicate] = object
      end
      data
    end

    def parse_body_as_ttl(str)
      data = {}
      reader =RDF::Graph.new << RDF::Turtle::Reader.new(str, {validate: true})
      reader.each_triple do |subject, predicate, object|
        data[predicate] = object
      end
      data
    end

  end

end
