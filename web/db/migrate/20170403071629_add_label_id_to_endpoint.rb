class AddLabelIdToEndpoint < ActiveRecord::Migration
  def change
    add_column :endpoints, :label_id, :integer
  end
end
