class AddSupportedLanguageToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :supported_language, :text
  end
end
