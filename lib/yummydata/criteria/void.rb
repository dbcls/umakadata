require 'yummydata/data_format'
require 'yummydata/http_helper'

module Yummydata
  module Criteria
    module VoID

      include Yummydata::DataFormat

      WELL_KNOWN_VOID_PATH = "/.well-known/void".freeze

      def void_on_well_known_uri(uri, time_out = 10)
        well_known_uri = URI::HTTP.build({:host => uri.host, :path => WELL_KNOWN_VOID_PATH})
        http_get_recursive(well_known_uri, time_out)
      end
    end
  end
end
