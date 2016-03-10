require 'yummydata/data_format'
require 'yummydata/http_helper'
require 'yummydata/void'

module Yummydata
  module Criteria
    module VoID

      include Yummydata::DataFormat

      WELL_KNOWN_VOID_PATH = "/.well-known/void".freeze

      def well_known_uri(uri)
        URI::HTTP.build({:host => uri.host, :path => WELL_KNOWN_VOID_PATH})
      end

      def void_on_well_known_uri(uri, time_out = 10)
        response = http_get_recursive(Yummydata::Criteria::VoID::well_known_uri(uri), {}, time_out)
        return nil if response.nil?
        return Yummydata::VoID.new(response)
      end

    end
  end
end
