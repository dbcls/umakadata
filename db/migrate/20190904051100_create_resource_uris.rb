class CreateResourceUris < ActiveRecord::Migration[5.2]
  def change
    create_table :resource_uris do |t|
      t.string :uri, null: false
      t.boolean :as_regex, null: false, default: false
      t.string :allow
      t.string :deny
      t.boolean :case_insensitive, null: false, default: false

      t.timestamps

      t.references :endpoint, foreign_key: true
    end
  end
end
