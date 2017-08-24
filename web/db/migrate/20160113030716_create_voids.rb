class CreateVoids < ActiveRecord::Migration
  def change
    create_table :voids do |t|
      t.integer :endpoint_id
      t.text :uri
      t.text :void_ttl

      t.timestamps null: false
    end
  end
end
