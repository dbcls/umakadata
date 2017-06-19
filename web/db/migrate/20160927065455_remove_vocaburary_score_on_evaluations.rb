class RemoveVocaburaryScoreOnEvaluations < ActiveRecord::Migration
  def change
    remove_column :evaluations, :vocabulary_score, :float
    remove_column :evaluations, :vocabulary_log, :text
  end
end
