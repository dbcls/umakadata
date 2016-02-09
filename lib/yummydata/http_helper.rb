require 'net/http'

module Yummydata
  module HTTPHelper

    def http_get(uri, headers, time_out)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = time_out
      path = uri.path.empty? ? '/' : uri.path

      begin
        return http.get(path, headers)
      rescue => e
        puts $!
        return nil
      end
    end

    def http_get_recursive(uri, time_out, limit = 10)
      raise RuntimeError, 'HTTP redirect too deep' if limit == 0

      p uri.to_s
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = time_out

      response = http.get(uri.path)
      case response
      when Net::HTTPSuccess
        body = response.body
        # raise ArgumentError, 'Invalid turtle format' unless ttl?(body)
        body
      when Net::HTTPRedirection
        http_get_recursive(URI(response['location']), time_out, limit - 1)
      else
        # raise corresponded exception
        response.value
      end
    end

  end
end
