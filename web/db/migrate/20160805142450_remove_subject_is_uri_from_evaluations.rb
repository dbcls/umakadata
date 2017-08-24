class RemoveSubjectIsUriFromEvaluations < ActiveRecord::Migration
  def change
    remove_column :evaluations, :subject_is_uri_log, :string
  end
end
