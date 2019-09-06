class CreateDatasetRelations < ActiveRecord::Migration[5.2]
  def change
    create_table :dataset_relations do |t|
      t.references :src_endpoint, foreign_key: { to_table: :endpoints }
      t.references :dst_endpoint, foreign_key: { to_table: :endpoints }
      t.string :relation
      t.references :endpoint, foreign_key: true

      t.timestamps
    end
  end
end
