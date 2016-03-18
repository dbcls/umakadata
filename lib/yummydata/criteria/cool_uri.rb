require 'yummydata/error_helper'

module Yummydata
  module Criteria
    module CoolURI

      include Yummydata::ErrorHelper

      def cool_uri_rate(uri)
        error = []
        rate = 0
        if uri.host !~ /\d+\.\d+\.\d+\.\d+/
          rate += 25
        else
          error.push('Host is IP')
        end
        if uri.port == 80
          rate += 25
        else
          error.push('Port is specified')
        end
        if uri.query.nil?
          rate += 25
        else
          error.push('URL query is specified')
        end
        if uri.to_s.length <= 30
          rate += 25
        else
          error.push('URI is longer than 30')
        end
        set_error(error.join(',')) if !error.empty?
        return rate
      end
    end
  end
end
