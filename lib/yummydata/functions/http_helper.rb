require 'net/http'

module Yummydata
  module Functions
    module HttpHelper
      def send_get_request(uri, headers, time_out)
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
    end
  end
end
