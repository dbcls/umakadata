class AddInsufficientLogColumnsToEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :cool_uri_rate_log, :text
    add_column :evaluations, :last_updated_log, :text
    add_column :evaluations, :vocabulary_log, :text
    add_column :evaluations, :ontology_log, :text
    add_column :evaluations, :support_turtle_format_log, :text
    add_column :evaluations, :support_xml_format_log, :text
    add_column :evaluations, :support_html_format_log, :text
  end
end
