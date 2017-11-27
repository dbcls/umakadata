class ChangeDatatypeNumberOfStatementsOfEvaluations < ActiveRecord::Migration
  def change
    change_column :evaluations, :number_of_statements, :bigint
  end
end
