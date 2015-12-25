require 'net/http'
require 'resolv-replace.rb'
require "rdf/turtle"
require 'rdf/rdfxml'

module Yummydata

  class ServiceDescription

    ##
    # return the type of service description
    #
    # @return [String]
    attr_reader :type

    ##
    # return service description
    #
    # @return [String]
    attr_reader :value

    ##
    # return response headers
    #
    # @return [String]
    attr_reader :response_header

    TYPE = {
      ttl: 'ttl',
      xml: 'xml',
      unknown: 'unknown'
    }.freeze

    def initialize(http_response)
      @type = TYPE[:unknown]
      @value = nil
      @response_header = ''

      if (!http_response.nil?)
        parse_body(http_response.body)

        http_response.each_key do |key|
          @response_header << key << ": " << http_response[key] << "\n"
        end
      end
    end

    private
    def parse_body(str)
      @value = str
      if xml?(str)
        @type = TYPE[:xml]
      elsif ttl?(str)
        @type = TYPE[:ttl]
      else
        @type = TYPE[:unknown]
        @value = nil
      end
    end

    def xml?(str)
      begin
        RDF::RDFXML::Reader.new(str, {:validate => true})
      rescue
        puts $!
        return false
      end
      return true
    end

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
    # @param       [Hash] opts
    # @option opts [Integer] :time_out Seconds to wait until connection is opened.
    # @return [Boolean]
    def alive?(opts={})
      opts = { time_out: 10 }.merge(opts)

      response = send_get_request(nil, opts[:time_out])
      response.is_a? Net::HTTPOK
    end

    ##
    # A string value that describes what services are provided at the SPARQL endpoint.
    # 
    # @param       [Hash] opts
    # @option opts [Integer] :time_out Seconds to wait until connection is opened.
    # @return      [Yummydata::ServiceDescription|nil]
    def service_description(opts={})
      opts = { time_out: 10 }.merge(opts)

      if @service_description && @service_description.valid?
        return @service_description
      end

      headers = {}
      headers['Accept'] = SERVICE_DESC_CONTEXT_TYPE.join(',')

      response = send_get_request(headers, opts[:time_out])
      @service_description = Yummydata::ServiceDescription.new(response)
    end

    private
    def send_get_request(headers, time_out)
      http = Net::HTTP.new(@uri.host, @uri.port)
      http.open_timeout = time_out
      path = @uri.path.empty? ? '/' : @uri.path

      rec_time {
        begin
          http.get(path, headers)
        rescue => e
          puts $!
          return nil
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
