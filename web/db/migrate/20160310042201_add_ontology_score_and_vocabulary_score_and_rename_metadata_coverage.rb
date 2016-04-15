class AddOntologyScoreAndVocabularyScoreAndRenameMetadataCoverage < ActiveRecord::Migration
  def change
    add_column :evaluations, :ontology_score, :float
    add_column :evaluations, :vocabulary_score, :float
    rename_column :evaluations, :metadata_coverage, :metadata_score
  end
end
