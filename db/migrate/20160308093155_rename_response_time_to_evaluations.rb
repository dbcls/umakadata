class RenameResponseTimeToEvaluations < ActiveRecord::Migration
  def change
    rename_column :evaluations, :response_time, :execution_time
  end
end
