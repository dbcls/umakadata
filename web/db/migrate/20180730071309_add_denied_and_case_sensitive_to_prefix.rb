class AddDeniedAndCaseSensitiveToPrefix < ActiveRecord::Migration
  def change
    add_column :prefixes, :denied_uri, :string
    add_column :prefixes, :case_sensitive, :boolean, default: true, null: false
  end
end
