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
        @text = http_response.body
        data = parse(@text, TTL)
        if (!data.nil?)
          @type = TYPE[:ttl]
        else
          data = parse(@text, XML)
          if (!data.nil?)
            @type = TYPE[:xml]
          end
        end
        @modified = if data.nil? ? 'N/A' : data['dcterms:modified']

        http_response.each_key do |key|
          @response_header << key << ": " << http_response[key] << "\n"
        end
      end
    end

  end
end
