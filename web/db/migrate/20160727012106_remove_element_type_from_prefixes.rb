class RemoveElementTypeFromPrefixes < ActiveRecord::Migration
  def change
    remove_column :prefixes, :element_type, :string
  end
end
