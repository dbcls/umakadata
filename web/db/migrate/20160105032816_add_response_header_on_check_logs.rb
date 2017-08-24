class AddResponseHeaderOnCheckLogs < ActiveRecord::Migration
  def change
    add_column :check_logs, :response_header, :text
  end
end
