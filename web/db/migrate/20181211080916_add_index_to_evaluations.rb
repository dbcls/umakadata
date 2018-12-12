class AddIndexToEvaluations < ActiveRecord::Migration
  def change
    add_index :evaluations, :crawl_log_id
  end
end
