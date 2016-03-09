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

    def initialize(http_response)
      @type = UNKNOWN
      @text = http_response.body
      @modified = ''

      data = triples(@text, TURTLE)
      if (!data.nil?)
        @type = TURTLE
      else
        data = triples(@text, RDFXML)
        if (!data.nil?)
          @type = RDFXML
        end
      end

      @response_header = ''
      http_response.each_key do |key|
        @response_header << key << ": " << http_response[key] << "\n"
      end
    end

  end
end
