class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.integer :endpoint_id
      t.string :uri
      t.string :element_type
      t.timestamps null: false
    end
  end
end
