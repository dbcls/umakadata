class AddColumnToEndpoint < ActiveRecord::Migration
  def change
    add_column :endpoints, :disable_crawling, :boolean, default: false, null: false
  end
end
