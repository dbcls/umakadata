class ChangeDatatypeOfCountOfUpdateStatuses < ActiveRecord::Migration
  def change
    change_column :update_statuses, :count, :bigint
  end
end
