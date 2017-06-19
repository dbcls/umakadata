class AddColumnSrcIdToRelations < ActiveRecord::Migration
  def change
    add_column :relations, :src_id, :integer
  end
end
