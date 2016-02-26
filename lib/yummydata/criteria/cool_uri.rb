module Yummydata
  module Criteria
    module CoolURI
      def cool_uri_rate(uri)
        rate = 0
        rate += 20 if uri.host !~ /\d+\.\d+\.\d+\.\d+/
        rate += 20 if uri.to_s == uri.to_s.downcase
        rate += 20 if uri.port == 80
        rate += 20 if uri.query.nil?
        rate += 20 if uri.to_s.length <= 30
        return rate
      end
    end
  end
end
