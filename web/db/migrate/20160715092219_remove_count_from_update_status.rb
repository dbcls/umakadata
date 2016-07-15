class RemoveCountFromUpdateStatus < ActiveRecord::Migration
  def change
    remove_column :update_statuses, :count, :integer
  end
end
