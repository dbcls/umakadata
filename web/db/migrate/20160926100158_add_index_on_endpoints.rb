class AddIndexOnEndpoints < ActiveRecord::Migration
  def change
    add_index :endpoints, :name, :unique => true
    add_index :endpoints, :url, :unique => true
  end
end
