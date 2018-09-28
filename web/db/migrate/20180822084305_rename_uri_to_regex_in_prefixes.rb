class RenameUriToRegexInPrefixes < ActiveRecord::Migration
  def change
    rename_column :prefixes, :allowed_uri, :allow_regex
    rename_column :prefixes, :denied_uri, :deny_regex
  end
end
