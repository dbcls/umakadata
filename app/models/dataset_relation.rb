class DatasetRelation < ApplicationRecord
  belongs_to :endpoint

  class << self
    def graph
      nodes = Endpoint.all.map do |endpoint|
        {
          group: 'nodes',
          data: {
            id: "n#{endpoint.id}",
            name: endpoint.name
          }
        }
      end

      relations = DatasetRelation
                    .preload(:endpoint)
                    .select(:src_endpoint_id, :dst_endpoint_id, :endpoint_id)
                    .distinct
                    .order(:src_endpoint_id)

      edges = relations.map.with_index { |relation, index|
        {
          group: 'edges',
          data: {
            id: "e#{index}",
            source: "n#{relation.src_endpoint_id}",
            target: "n#{relation.dst_endpoint_id}",
            label: relation.endpoint.name
          }
        }
      }

      edges.reject! { |edge| edge[:data][:source] == edge[:data][:target] }

      nodes.concat(edges)
    end
  end
end
