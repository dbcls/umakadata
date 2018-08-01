class RenameUriToAllowedUriInPrefixes < ActiveRecord::Migration
  def change
    rename_column :prefixes, :uri, :allowed_uri
  end
end
