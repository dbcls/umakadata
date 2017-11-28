class AddViewerUrlColumnToEndpoint < ActiveRecord::Migration
  def change
    add_column :endpoints, :viewer_url, :string
  end
end
