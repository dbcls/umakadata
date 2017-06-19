class AddLastUpdatedOnEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :last_updated, :date
  end
end
