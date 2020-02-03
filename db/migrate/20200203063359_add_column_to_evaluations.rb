class AddColumnToEvaluations < ActiveRecord::Migration[5.2]
  def change
    add_column :evaluations, :started_at, :datetime
    add_column :evaluations, :finished_at, :datetime
  end
end
