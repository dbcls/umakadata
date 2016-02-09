require 'yummydata/data_format'
require "yummydata/service_description"

module Yummydata
  module Criteria
    module ServiceDescription

      include Yummydata::HTTPHelper

      SERVICE_DESC_CONTEXT_TYPE = %w(text/turtle application/rdf+xml).freeze

      ##
      # A string value that describes what services are provided at the SPARQL endpoint.
      #
      # @param       [Hash] opts
      # @option opts [Integer] :time_out Seconds to wait until connection is opened.
      # @return      [Yummydata::ServiceDescription|nil]
      def service_description(uri, time_out)
        headers = {}
        headers['Accept'] = SERVICE_DESC_CONTEXT_TYPE.join(',')

        response = http_get(uri, headers, time_out)

        return Yummydata::ServiceDescription.new(response)
      end
    end
  end
end
