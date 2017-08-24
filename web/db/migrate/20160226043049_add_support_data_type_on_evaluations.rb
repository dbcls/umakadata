class AddSupportDataTypeOnEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :support_content_negotiation, :boolean
    add_column :evaluations, :support_turtle_format, :boolean
    add_column :evaluations, :support_xml_format, :boolean
    add_column :evaluations, :support_html_format, :boolean
  end
end
