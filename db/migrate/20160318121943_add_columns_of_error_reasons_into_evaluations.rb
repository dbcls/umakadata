class AddColumnsOfErrorReasonsIntoEvaluations < ActiveRecord::Migration
  def change
    add_column :evaluations, :alive_error_reason, :text
    add_column :evaluations, :service_description_error_reason, :text
    add_column :evaluations, :uri_subject_error_reason, :text
    add_column :evaluations, :subject_is_uri_error_reason, :text
    add_column :evaluations, :subject_is_http_uri_error_reason, :text
    add_column :evaluations, :uri_provides_info_error_reason, :text
    add_column :evaluations, :contains_links_error_reason, :text
    add_column :evaluations, :void_ttl_error_reason, :text
    add_column :evaluations, :execution_time_error_reason, :text
    add_column :evaluations, :support_content_negotiation_error_reason, :text
    add_column :evaluations, :metadata_error_reason, :text
    add_column :evaluations, :number_of_statements_error_reason, :text
  end
end
