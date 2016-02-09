require "yummydata/functions/liveness"
require "yummydata/functions/service_description"
require "yummydata/functions/linked_data_rules"

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

    include Yummydata::Functions::LinkedDataRules
    def uri_subject?
      super(@uri)
    end
    def http_subject?
      super(@uri)
    end
    def uri_provides_info?
      super(@uri)
    end
    def contains_links?
      super(@uri)
    end

  end
end
