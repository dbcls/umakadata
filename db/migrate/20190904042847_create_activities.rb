class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.string :name
      t.text :request
      t.text :response
      t.float :elapsed_time
      t.string :trace
      t.string :warnings
      t.binary :errors

      t.references :measurement, foreign_key: true
    end
  end
end
