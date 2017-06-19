class CreateUpdateStatuses < ActiveRecord::Migration
  def change
    create_table :update_statuses do |t|
      t.integer :endpoint_id
      t.integer :count
      t.text :first
      t.text :last

      t.timestamps null: false
    end
  end
end
