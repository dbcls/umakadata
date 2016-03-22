require "yummydata/http_helper"
require "yummydata/error_helper"

module Yummydata
  module Criteria
    module Liveness

      include Yummydata::HTTPHelper
      include Yummydata::ErrorHelper

      ##
      # A boolan value whether if the SPARQL endpoint is alive.
      #
      # @param  uri [URI]: the target endpoint
      # @param  time_out [Integer]: the period in seconds to wait for a connection
      # @return [Boolean]
      def alive?(uri, time_out)
        response = http_get(uri, nil, time_out)
        if response.is_a? Net::HTTPOK
          return true
        else
          set_error(response)
          return false
        end
      end
    end
  end
end
