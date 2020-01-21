class AddColumnToAdminUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :admin_users, :notification, :bool, default: false
  end
end
