class AddColumnToEvaluation < ActiveRecord::Migration
  def change
    add_column :evaluations, :response_time, :float
  end
end
