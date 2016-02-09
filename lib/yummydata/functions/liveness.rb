require "yummydata/functions/http_helper"

module Yummydata
  module Functions
    module Liveness
      include HttpHelper

      ##
      # A boolan value whether if the SPARQL endpoint is alive.
      #
      # @param  uri [URI]: the target endpoint
      # @param  time_out [Integer]: the period in seconds to wait for a connection
      # @return [Boolean]
      def alive?(uri, time_out)
        response = send_get_request(uri, nil, time_out)
        response.is_a? Net::HTTPOK
      end
    end
  end
end
