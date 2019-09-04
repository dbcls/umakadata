class CreateMeasurements < ActiveRecord::Migration[5.2]
  def change
    create_table :measurements do |t|
      t.string :name
      t.string :value
      t.string :comment
      t.datetime :started_at
      t.datetime :finished_at

      t.references :evaluation, foreign_key: true
    end
  end
end
