class AddIndexForEndpointIdOnEvaluations < ActiveRecord::Migration
  def change
    add_index :evaluations, :endpoint_id
  end
end
