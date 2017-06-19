class CreatePrefixes < ActiveRecord::Migration
  def change
    create_table :prefixes do |t|
      t.integer :endpoint_id
      t.string :uri
      t.string :element_type
      t.timestamps null: false
    end
  end
end
