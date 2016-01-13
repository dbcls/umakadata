require 'net/http'
require 'rdf/turtle'

module Yummydata

  class WellKnownVoid

    WELL_KNOWN_VOID_PATH = "/.well-known/void"

    def initialize(uri)
      @uri = URI(uri)
    end

    def self.well_known_uri(uri)
      URI::HTTP.build({:host => URI(uri).host, :path => WELL_KNOWN_VOID_PATH})
    end

    def get_ttl(opts={})
      opts = { time_out: 10 }.merge(opts)
      
      uri = WellKnownVoid::well_known_uri(@uri)

      get_response_recursive(uri, opts[:time_out])
    end

    private
    def get_response_recursive(uri, time_out, limit = 10)
      # TODO define better exception
      raise ArgumentError, 'HTTP redirect too deep' if limit == 0

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
        get_response_recursive(URI(response['location']), time_out, limit - 1)
      else
        # raise corresponded exception
        response.value
      end

    end

    # TODO same codes in endpoint.rb
    def ttl?(str)
      begin
        ttl = RDF::Graph.new << RDF::Turtle::Reader.new(str, {:validate => true})
        raise RDF::ReaderError.new "Empty turtle." if ttl.count == 0
      rescue
        puts $!
        return false
      end
      return true
    end

  end

end
