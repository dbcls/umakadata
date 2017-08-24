class AddColumnToEvaluation < ActiveRecord::Migration
  def change
    add_column :evaluations, :execution_time, :float
  end
end
