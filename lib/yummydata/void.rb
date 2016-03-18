require 'rdf/turtle'
require 'yummydata/data_format'
require 'yummydata/error_helper'

module Yummydata

  class VoID

    include Yummydata::DataFormat
    include Yummydata::ErrorHelper

    ##
    # return the VoID as string
    #
    # @return [String]
    attr_reader :text

    ##
    # return the license of VoID
    #
    # @return [Array]
    attr_reader :license

    ##
    # return the publisher of VoID
    #
    # @return [Array]
    attr_reader :publisher

    ##
    # return the last_modified of some VoID data
    #
    # @return [String]
    attr_reader :modified

    def initialize(http_response)
      if !http_response.is_a?(Net::HTTPSuccess)
        set_error(http_response)
        return
      end
      @text = http_response.body
      data = triples(@text, TURTLE)
      data = triples(@text, RDFXML) if data.nil?
      return if data.nil?

      @license = []
      @publisher = []
      @modified = []
      data.each do |subject, predicate, object|
        @license.push object.to_s if predicate == RDF::URI('http://purl.org/dc/terms/license')
        @publisher.push object.to_s if predicate == RDF::URI('http://purl.org/dc/terms/publisher')
        @modified.push object.to_s if predicate == RDF::URI('http://purl.org/dc/terms/modified')
      end

      @modified =  @modified.empty? ? nil : @modified[0]
    end
  end
end
