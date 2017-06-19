class RemoveSupportedLanguageFromEvaluations < ActiveRecord::Migration
  def change
    remove_column :evaluations, :supported_language, :text
  end
end
