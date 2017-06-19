class AddColumnsToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :supported_language, :string
    add_column :evaluations, :linksets, :text
    add_column :evaluations, :license, :text
    add_column :evaluations, :publisher, :text
  end
end
