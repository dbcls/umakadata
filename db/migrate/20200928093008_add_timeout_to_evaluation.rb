class AddTimeoutToEvaluation < ActiveRecord::Migration[5.2]
  def change
    add_column :evaluations, :timeout, :boolean
  end
end
