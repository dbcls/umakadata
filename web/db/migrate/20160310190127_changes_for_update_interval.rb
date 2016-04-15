class ChangesForUpdateInterval < ActiveRecord::Migration
  def change
    remove_column :endpoints, :last_updated
    add_column :evaluations, :last_updated, :date
    add_column :evaluations, :last_updated_source, :text
    add_column :evaluations, :update_interval, :integer

    drop_table :check_logs
    drop_table :endpoint_update_infos
    drop_table :linked_data_rules
    drop_table :voids
    drop_table :scores
  end
end
