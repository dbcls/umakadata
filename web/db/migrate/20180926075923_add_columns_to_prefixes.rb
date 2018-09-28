class AddColumnsToPrefixes < ActiveRecord::Migration
  def change
    add_column :prefixes, :as_regex, :boolean, default: false
    add_column :prefixes, :use_fixed_uri, :boolean, default: false
    add_column :prefixes, :fixed_uri, :string
  end
end
