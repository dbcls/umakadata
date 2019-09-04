class CreateVocabularyPrefixes < ActiveRecord::Migration[5.2]
  def change
    create_table :vocabulary_prefixes do |t|
      t.string :uri, null: false
      t.references :endpoint, foreign_key: true

      t.timestamps
    end

    add_index :vocabulary_prefixes, :uri
  end
end
