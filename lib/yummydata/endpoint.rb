module Yummydata

  class Endpoint

    SERVICE_DESC_CONTEXT_TYPE = %w(text/turtle application/rdf+xml).freeze

    ##
    # The time that the last query taken to get the results
    #
    # @return [Number]
    attr_reader :last_response_time

    def initialize(uri)
      @uri = URI(uri)
      @service_description = nil
    end

    ##
    # A boolan value whether if the SPARQL endpoint is alive.
    #
    # @return [Boolean]
    def is_alive?
      response = send_get_request(nil)
      response.is_a? Net::HTTPOK
    end

    ##
    # A string value that describes what services are provided at the SPARQL endpoint.
    #
    # @return [String|nil]
    def get_service_description
      if @service_description && !@service_description.empty?
        return @service_description
      end

      headers = {}
      headers['Accept'] = SERVICE_DESC_CONTEXT_TYPE.join(',')

      response = send_get_request(headers)
      # TODO add validation of description

      if response.is_a? Net::HTTPSuccess && !response.body.empty?
        @service_description = response.body
      else
        @service_description = nil
      end
    end

    private
    def send_get_request(headers)
      http = Net::HTTP.new(@uri.host, @uri.port)
      path = @uri.path.empty? ? '/' : @uri.path

      rec_time {
        begin
          http.get(path, headers)
        rescue
          nil
        end
      }
    end

    def rec_time(&block)
      start = Time.now.usec
      return_value = block.call
      time = Time.now.usec - start
      @last_response_time = time > 0 ? (time / 1000.0).round : 0

      return_value
    end

  end

end
