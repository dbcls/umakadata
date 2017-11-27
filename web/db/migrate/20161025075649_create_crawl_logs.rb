class CreateCrawlLogs < ActiveRecord::Migration
  def change
    create_table :crawl_logs do |t|
      t.datetime :started_at, null: false
      t.datetime :finished_at
    end
  end
end
