class AddIssueIdOnEndpoints < ActiveRecord::Migration
  def change
    add_column :endpoints, :issue_id, :integer
  end
end
