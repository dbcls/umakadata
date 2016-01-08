class ChangeDatatypeOfServiceDescriptionOnCheckLogs < ActiveRecord::Migration
  def change
    change_column :check_logs, :service_description, :text
  end
end
