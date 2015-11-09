class CreateEndpointUpdateInfos < ActiveRecord::Migration
  def change
    create_table :endpoint_update_infos do |t|
      t.integer :endpoint_id
      t.integer :num_of_triples
      t.text    :samples

      t.timestamps null: false
    end
  end
end
