require 'sparql/client'

module Yummydata
  module Criteria
    module LastUpdate



      include Yummydata::Criteria::ServiceDescription
      include Yummydata::Criteria::VoID

      COUNT_QUERY = <<-'SPARQL'
select count (*) where {?s ?p ?o}
SPARQL


      def initialize(uri)
          @client = ''
          @uri = uri
      end

      def last_modified
          sd = service_description(@uri)
          return sd.dc if sd contains last update

          void = void(@uri)
          return xxx if void contains last_update

          response = @client.request(MODIFIED_QUERY)
          return nil if response.nil?

          response[:last_update]
      end

      def count_first_last
          # DO SOMETHING
      end

    end
  end
end
