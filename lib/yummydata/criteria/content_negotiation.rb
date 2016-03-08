require 'yummydata/http_helper'

module Yummydata
  module Criteria
    module ContentNegotiation

      include Yummydata::HTTPHelper

      def check_content_negotiation(uri, content_type)
        query = <<-'SPARQL'
SELECT
  *
WHERE {
        GRAPH ?g { ?s ?p ?o } .
      }
LIMIT 1
SPARQL

        headers = {}
        headers['Accept'] = content_type
        request =  URI(uri.to_s + "?query=" + query)

        response = http_get(request, headers)

        return response.content_type == content_type
      end
    end
  end
end
