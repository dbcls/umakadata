require 'yummydata/http_helper'
require 'yummydata/data_format'
require "yummydata/service_description"

module Yummydata
  module Criteria
    module ServiceDescription

      include Yummydata::HTTPHelper

      SERVICE_DESC_CONTEXT_TYPE = [Yummydata::DataFormat::TURTLE, Yummydata::DataFormat::RDFXML].freeze

      ##
      # A string value that describes what services are provided at the SPARQL endpoint.
      #
      # @param       [Hash] opts
      # @option opts [Integer] :time_out Seconds to wait until connection is opened.
      # @return      [Yummydata::ServiceDescription|nil]
      def service_description(uri, time_out, content_type = nil)
        headers = {}
        headers['Accept'] = content_type
        headers['Accept'] ||= SERVICE_DESC_CONTEXT_TYPE.join(',')

        response = http_get(uri, headers, time_out)

        if !response.is_a?(Net::HTTPSuccess)
          if response.is_a? Net::HTTPResponse
            set_error(response.code + "\s" + response.message)
          else
            set_error(response)
          end
        end

        sd = Yummydata::ServiceDescription.new(response)

        if sd.text.nil?
          set_error("data format is not accepted")
        end
        return sd
      end
    end
  end
end
