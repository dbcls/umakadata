class AddCrawlLogIdToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :crawl_log_id, :integer
  end
end
