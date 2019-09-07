class CreateActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :activities do |t|
      t.string :name
      t.string :comment
      t.binary :request
      t.binary :response
      t.float :elapsed_time
      t.string :trace
      t.string :warnings
      t.binary :exceptions

      t.references :measurement, foreign_key: true
    end
  end
end
