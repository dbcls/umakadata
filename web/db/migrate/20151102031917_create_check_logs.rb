class CreateCheckLogs < ActiveRecord::Migration
  def change
    create_table :check_logs do |t|
      t.integer :endpoint_id
      t.boolean :alive
      t.boolean :service_description

      t.timestamps null: false
    end
  end
end
