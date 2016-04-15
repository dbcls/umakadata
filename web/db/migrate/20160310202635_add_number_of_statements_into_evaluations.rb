class AddNumberOfStatementsIntoEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :number_of_statements, :integer
  end
end
