class CreateGraphs < ActiveRecord::Migration[5.2]
  def change
    create_table :graphs do |t|
      t.references :endpoint, foreign_key: true

      t.integer :mode, default: 0, null: false
      t.text :graphs, null: false

      t.timestamps
    end
  end
end
