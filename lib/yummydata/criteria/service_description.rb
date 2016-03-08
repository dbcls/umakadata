require 'yummydata/data_format'
require "yummydata/service_description"
require "yummydata/content_types"

module Yummydata
  module Criteria
    module ServiceDescription

      include Yummydata::HTTPHelper

      SERVICE_DESC_CONTEXT_TYPE = [CONTENT_TYPE_TURTLE, CONTENT_TYPE_RDFXML].freeze

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

        return Yummydata::ServiceDescription.new(response)
      end
    end
  end
end
