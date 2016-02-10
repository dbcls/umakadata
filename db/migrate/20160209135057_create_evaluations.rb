class CreateEvaluations < ActiveRecord::Migration
  def change
    create_table :evaluations do |t|
      t.integer :endpoint_id

      t.boolean :latest

      t.boolean :alive
      t.float :alive_rate
      t.text :response_header
      t.text :service_description
      t.text :void_uri
      t.text :void_ttl

      t.boolean :subject_is_uri
      t.boolean :subject_is_http_uri
      t.boolean :uri_provides_info
      t.boolean :contains_links

      t.integer :score
      t.integer :rank

      t.timestamps null: false
    end
  end
end
