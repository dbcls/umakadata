require 'sparql/client'

module Yummydata

  class LastUpdate

    def initialize(url)
      @client = SPARQL::Client.new url
      @info = nil
    end

    def updated? info
      num = num_of_triples
      if info[:num_of_triples] == num
        offsets = info[:samples].keys
      else
        offsets = []
        for i in 0..9 do
          offsets << (num.to_i * Random.rand(0.9)).to_i
        end
      end
      samples = sampling(offsets)
      @info = { num_of_triples: num.to_s, samples: samples }

      info[:num_of_triples] != @info[:num_of_triples] || different?(info[:samples], @info[:samples])
    end

    def info
      @info
    end

    def num_of_triples
      sparql_query = <<-'SPARQL'
SELECT
  (COUNT(*) AS ?no)
WHERE
  { ?s ?p ?o }
SPARQL
      begin
        results = @client.query(sparql_query)
        if results
          results[0][:no]
        else
          nil
        end
      rescue
        nil
      end
    end

    def sampling(offsets)
      samples = {}
      offsets.each do |offset|
        sparql_query = <<-SPARQL
SELECT
  *
WHERE
  { ?s ?p ?o }
OFFSET
  #{offset}
LIMIT
  1
SPARQL
        begin
          results = @client.query(sparql_query)
          if results
            samples[offset] = {subject: results[0][:s].to_s, predicate: results[0][:p].to_s, object: results[0][:o].to_s}
          else
            samples[offset] = nil
          end
        rescue
          samples[offset] = nil
        end
      end
      samples
    end

    def different?(lhs, rhs)
      if lhs.count != rhs.count
        return true
      end
      lhs.each_with_index do |item, index|
        if (item[:s] != rhs[index][:s] || item[:p] != rhs[index][:p] || item[:o] != rhs[index][:o])
          return true
        end
      end
      return false
    end

  end

end
