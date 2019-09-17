class CreateEvaluations < ActiveRecord::Migration[5.2]
  def change
    create_table :evaluations do |t|
      # Basic information
      t.string :publisher
      t.string :license
      t.string :language
      t.boolean :service_keyword, null: false, default: false
      t.boolean :graph_keyword, null: false, default: false
      t.decimal :data_scale
      t.integer :score, null: false, default: 0
      t.integer :rank, null: false, default: 0
      t.boolean :cors, null: false, default: false

      # Availability
      t.boolean :alive, null: false, default: false
      t.float :alive_rate, null: false, default: 0

      # Freshness
      t.date :last_updated

      # Operation
      t.boolean :service_description, null: false, default: false
      t.boolean :void, null: false, default: false

      # Usefulness
      t.float :metadata, null: false, default: 0
      t.float :ontology, null: false, default: 0
      t.string :links_to_other_datasets
      t.bigint :data_entry
      t.boolean :support_html_format, null: false, default: false
      t.boolean :support_rdfxml_format, null: false, default: false
      t.boolean :support_turtle_format, null: false, default: false

      # Validity
      t.float :cool_uri, null: false, default: 0
      t.boolean :http_uri, null: false, default: false
      t.boolean :provide_useful_information, null: false, default: false
      t.boolean :link_to_other_uri, null: false, default: false

      # Performance
      t.float :execution_time

      t.timestamps

      t.references :endpoint, foreign_key: true
      t.references :crawl, foreign_key: true
    end

    add_index :evaluations, :created_at
    add_index :evaluations, :updated_at
  end
end
