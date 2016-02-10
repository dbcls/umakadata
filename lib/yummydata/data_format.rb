module Yummydata
  module DataFormat
    def xml?(str)
      begin
        RDF::RDFXML::Reader.new(str, {validate: true})
      rescue
        return false
      end
      return true
    end

    def ttl?(str)
      begin
        ttl = RDF::Graph.new << RDF::Turtle::Reader.new(str, {validate: true})
        return false if ttl.count == 0
      rescue
        return false
      end
      return true
    end
  end
end
