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

    TYPE = {
      ttl: 'ttl',
      xml: 'xml',
      unknown: 'unknown'
    }.freeze

    def initialize(http_response)
      @type = TYPE[:unknown]
      @text = ''
      @response_header = ''

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
      elsif ttl?(str)
        @type = TYPE[:ttl]
      else
        @type = TYPE[:unknown]
        @text = ''
      end
    end


  end

end
