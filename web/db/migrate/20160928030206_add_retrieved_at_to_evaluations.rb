class AddRetrievedAtToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :retrieved_at, :datetime
  end
end
