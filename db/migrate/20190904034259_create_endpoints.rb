class CreateEndpoints < ActiveRecord::Migration[5.2]
  def change
    create_table :endpoints do |t|
      t.string :name, null: false
      t.string :endpoint_url, null: false
      t.string :description_url
      t.boolean :enabled, null: false, default: true
      t.string :viewer_url
      t.integer :issue_id
      t.integer :label_id

      t.timestamps
    end

    add_index :endpoints, :name, unique: true
    add_index :endpoints, :endpoint_url, unique: true
    add_index :endpoints, :issue_id, unique: true
    add_index :endpoints, :label_id, unique: true
  end
end
