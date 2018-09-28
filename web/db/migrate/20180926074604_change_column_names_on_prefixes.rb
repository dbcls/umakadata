class ChangeColumnNamesOnPrefixes < ActiveRecord::Migration
  def change
    rename_column :prefixes, :allow_regex, :allow
    rename_column :prefixes, :deny_regex, :deny
    rename_column :prefixes, :case_sensitive, :case_insensitive
    change_column_default :prefixes, :case_insensitive, false
  end
end
