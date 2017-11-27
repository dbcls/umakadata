class AddMetadataCoverageOnEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :metadata_coverage, :float
  end
end
