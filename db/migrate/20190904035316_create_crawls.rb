class CreateCrawls < ActiveRecord::Migration[5.2]
  def change
    create_table :crawls do |t|
      t.datetime :started_at
      t.datetime :finished_at
    end

    add_index :crawls, :started_at
    add_index :crawls, :finished_at
  end
end
