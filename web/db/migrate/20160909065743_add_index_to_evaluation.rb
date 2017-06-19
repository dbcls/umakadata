class AddIndexToEvaluation < ActiveRecord::Migration
  def change
    add_index :evaluations, :created_at
  end
end
