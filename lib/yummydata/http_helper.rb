require 'net/http'

module Yummydata
  module HTTPHelper

    def http_get(uri, headers, time_out = 10)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = time_out
      path = uri.path.empty? ? '/' : uri.path

      begin
        return http.get(path, headers)
      rescue => e
        return nil
      end
    end

    def http_get_recursive(uri, time_out, limit = 10)
      raise RuntimeError, 'HTTP redirect too deep' if limit == 0

      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = time_out

      begin
        response = http.get(uri.path)
      rescue => e
        return nil
      end

      case response
      when Net::HTTPSuccess
        body = response.body
      when Net::HTTPRedirection
        http_get_recursive(URI(response['location']), time_out, limit - 1)
      else
        nil
      end
    end

  end
end
