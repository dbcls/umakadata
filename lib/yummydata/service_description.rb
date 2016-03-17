require 'yummydata/data_format'
require 'yummydata/error_helper'

module Yummydata

  class ServiceDescription

    include Yummydata::DataFormat
    include Yummydata::ErrorHelper
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
      @text = nil
      @modified = nil
      @response_header = ''
      if http_response.is_a?(String)
        set_error(http_response)
        return
      end
      body = http_response.body
      data = triples(body, TURTLE)
      if (!data.nil?)
        @text = body
        @type = TURTLE
      else
        data = triples(body, RDFXML)
        if (!data.nil?)
          @text = body
          @type = RDFXML
        else
          set_error("Neither turtle nor rdfxml")
          return
        end
      end

      data.each do |subject, predicate, object|
        if predicate == RDF::URI("http://purl.org/dc/terms/modified")
          @modified = object.to_s
          break
        end
      end

      http_response.each_key do |key|
        @response_header << key << ": " << http_response[key] << "\n"
      end
      set_error("response_header is empty") if @response_header.empty?
    end

  end
end
