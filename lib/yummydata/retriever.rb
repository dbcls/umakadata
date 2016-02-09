require "yummydata/functions/liveness"
require "yummydata/functions/service_description"

module Yummydata
  class Retriever

    def initialize(uri)
      @uri = URI(uri)
    end

    include Yummydata::Functions::Liveness
    def alive?(time_out = 10)
      super(@uri, time_out)
    end

    include Yummydata::Functions::ServiceDescription
    def service_description(time_out = 10)
      super(@uri, time_out)
    end

  end
end
