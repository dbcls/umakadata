class CreateRelations < ActiveRecord::Migration
  def change
    create_table :relations do |t|
      t.integer :endpoint_id
      t.integer :dst_id
      t.text :name
      t.timestamps null: false
    end
  end
end
