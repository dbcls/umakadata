class ChangeDataTypeForIssueIdAndLabelId < ActiveRecord::Migration[5.2]
  def change
    change_table :endpoints do |t|
      t.change :issue_id, :bigint
      t.change :label_id, :bigint
    end
  end
end
