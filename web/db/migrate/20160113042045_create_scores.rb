class CreateScores < ActiveRecord::Migration
  def change
    create_table :scores do |t|
      t.integer :endpoint_id
      t.integer :score
      t.integer :rank

      t.timestamps null: false
    end
  end
end
