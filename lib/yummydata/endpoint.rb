module Yummydata

  class Endpoint

    ##
    # The time that the last query taken to get the results
    #
    # @return [Number]
    attr_reader :last_response_time

    def initialize(uri)
      @uri = URI(uri)
    end

    ##
    # A boolan value whether if the SPARQL endpoint is alive.
    #
    # @return [Boolean]
    def is_alive?
      response = send_get_request(nil)
      response.is_a? Net::HTTPOK
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
