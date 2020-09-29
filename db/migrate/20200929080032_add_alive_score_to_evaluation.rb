class AddAliveScoreToEvaluation < ActiveRecord::Migration[5.2]
  def change
    add_column :evaluations, :alive_score, :float
  end
end
