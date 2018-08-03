class CreateLinkedOpenVocabularies < ActiveRecord::Migration
  def change
    create_table :linked_open_vocabularies do |t|
      t.text :list_ontologies
      t.timestamps null: false
    end
  end
end
