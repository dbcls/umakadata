class AddSupportGraphClauseToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :support_graph_clause, :boolean
  end
end
