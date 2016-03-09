require 'rdf/turtle'
require 'yummydata/data_format'

module Yummydata

  class VoID

    include Yummydata::DataFormat

    ##
    # return the license of VoID
    #
    # @return [String]
    attr_reader :license

    ##
    # return the publisher of VoID
    #
    # @return [String]
    attr_reader :publisher

    ##
    # return the last_modified of some VoID data
    #
    # @return [String]
    attr_reader :last_modified

    def initialize(http_response)
      @license = []
      @publisher = []
      @last_modified = ''

      if (!http_response.nil?)
        text = http_response.body
        data = parse(text, TTL)
        if (!data.nil?)
          data.each do |subject, predicate, object|
            @licanse.push object.to_s if predicate == RDF::URI('http://purl.org/dc/terms/license')
            @publisher.push object.to_s if predicate == RDF::URI('http://purl.org/dc/terms/publisher')
          end
        else
          data = parse(text, XML)
          if (!data.nil?)
            data.each do |subject, predicate, object|
              @licanse.push object.to_s if predicate == RDF::URI('http://purl.org/dc/terms/license')
              @publisher.push object.to_s if predicate == RDF::URI('http://purl.org/dc/terms/publisher')
            end
          end
        end
        @modified = if data.nil? ? 'N/A' : data['dcterms:modified']
        @license = @license.join('<br/>')
        @publisher = @publisher.join('<br/>')
      end
    end

  end
end
