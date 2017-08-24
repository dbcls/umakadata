class AddDescriptionUrlOnEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :description_url, :string
  end
end
