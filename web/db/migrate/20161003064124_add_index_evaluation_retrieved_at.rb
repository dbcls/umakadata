class AddIndexEvaluationRetrievedAt < ActiveRecord::Migration
  def change
    add_index :evaluations, :retrieved_at
  end
end
