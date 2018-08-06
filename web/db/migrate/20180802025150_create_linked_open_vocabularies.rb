class CreateLinkedOpenVocabularies < ActiveRecord::Migration
  def change
    create_table :linked_open_vocabularies do |t|
      t.text :uri
      t.timestamps null: false
    end
  end
end
