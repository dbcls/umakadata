class AddSupportServiceClause < ActiveRecord::Migration
  def change
    add_column :evaluations, :support_service_clause, :boolean
    add_column :evaluations, :support_service_clause_log, :text
  end
end
