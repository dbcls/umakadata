require "yummydata/criteria/liveness"
require "yummydata/criteria/service_description"
require "yummydata/criteria/linked_data_rules"
require "yummydata/criteria/void"
require "yummydata/criteria/execution_time"
require "yummydata/criteria/cool_uri"
require "yummydata/criteria/content_negotiation"
require "yummydata/criteria/metadata"

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

    include Yummydata::Criteria::ExecutionTime
    def execution_time
      super(@uri)
    end

    include Yummydata::Criteria::CoolURI
    def cool_uri_rate
      super(@uri)
    end

    include Yummydata::Criteria::ContentNegotiation
    def check_content_negotiation(content_type)
      super(@uri, content_type)
    end

    include Yummydata::Criteria::Metadata
    def check_metadata
      results = [
        self.list_of_graph_uris(@uri),
        self.list_of_classes_on_graph(@uri),
        self.list_of_classes_having_instances(@uri),
        self.list_of_labels_of_a_class(@uri),
        self.list_of_labels_of_classes(@uri),
        self.number_of_instances_of_class_on_a_graph(@uri),
        self.list_of_domain_classes_of_property_on_graph1(@uri),
        self.list_of_domain_classes_of_property_on_graph2(@uri),
        self.list_of_range_classes_of_property_on_graph(@uri),
        self.list_of_class_class_relationships(@uri),
        self.list_of_class_datatype_relationships(@uri),
        self.number_of_elements1(@uri),
        self.number_of_elements2(@uri),
        self.number_of_elements3(@uri),
        self.number_of_elements4(@uri),
        self.number_of_elements5(@uri),
        self.number_of_elements6(@uri),
        self.list_of_properties_domains_ranges(@uri),
        self.list_of_datatypes(@uri)
      ]
      return results.count(true).to_f / results.count.to_f * 100.0
    end

  end
end
