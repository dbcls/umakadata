class DropExcludingGraphs < ActiveRecord::Migration[5.2]
  def change
    drop_table :excluding_graphs do |t|
      t.string :uri
      t.references :endpoint, foreign_key: true

      t.timestamps
    end
  end
end
