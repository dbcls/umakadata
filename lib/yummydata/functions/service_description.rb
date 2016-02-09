require "yummydata/service_description"

module Yummydata
  module Functions
    module ServiceDescription
      ##
      # A string value that describes what services are provided at the SPARQL endpoint.
      #
      # @param       [Hash] opts
      # @option opts [Integer] :time_out Seconds to wait until connection is opened.
      # @return      [Yummydata::ServiceDescription|nil]
      def service_description(uri, time_out)
        headers = {}
        headers['Accept'] = SERVICE_DESC_CONTEXT_TYPE.join(',')

        response = send_get_request(uri, headers, time_out)

        return Yummydata::ServiceDescription.new(response)
      end
    end
  end
end
