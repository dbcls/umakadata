class AddTimeoutToEndpoint < ActiveRecord::Migration[5.2]
  def change
    add_column :endpoints, :timeout, :float, default: 4.0
  end
end
