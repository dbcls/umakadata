class CreateLinkedDataRules < ActiveRecord::Migration
  def change
    create_table :linked_data_rules do |t|
      t.integer :endpoint_id
      t.boolean :subject_is_uri
      t.boolean :subject_is_http_uri
      t.boolean :uri_provides_info
      t.boolean :contains_links

      t.timestamps null: false
    end
  end
end
