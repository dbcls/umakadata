require "yummydata/http_helper"

module Yummydata
  module Criteria
    module Liveness

      include Yummydata::HTTPHelper

      ##
      # A boolan value whether if the SPARQL endpoint is alive.
      #
      # @param  uri [URI]: the target endpoint
      # @param  time_out [Integer]: the period in seconds to wait for a connection
      # @return [Boolean]
      def alive?(uri, time_out)
        response = http_get(uri, nil, time_out)
        response.is_a? Net::HTTPOK
      end
    end
  end
end
