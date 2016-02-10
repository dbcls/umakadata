require "yummydata/criteria/liveness"
require "yummydata/criteria/service_description"
require "yummydata/criteria/linked_data_rules"
require "yummydata/criteria/void"

module Yummydata
  class Retriever

    def initialize(uri)
      @uri = URI(uri)
    end

    include Yummydata::Criteria::Liveness
    def alive?(time_out = 30)
      super(@uri, time_out)
    end

    include Yummydata::Criteria::ServiceDescription
    def service_description(time_out = 30)
      super(@uri, time_out)
    end

    include Yummydata::Criteria::LinkedDataRules
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

    include Yummydata::Criteria::VoID
    def well_known_uri
      super(@uri)
    end
    def void_on_well_known_uri(time_out = 30)
      super(@uri, time_out)
    end

  end
end
