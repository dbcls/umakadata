class AddSkipFlagToCrawl < ActiveRecord::Migration[5.2]
  def change
    add_column :crawls, :skip, :boolean
  end
end
