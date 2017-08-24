class CreateRdfPrefixes < ActiveRecord::Migration
  def change
    create_table :rdf_prefixes do |t|
      t.integer :endpoint_id
      t.string :uri
      t.timestamps null: false
    end
  end
end
