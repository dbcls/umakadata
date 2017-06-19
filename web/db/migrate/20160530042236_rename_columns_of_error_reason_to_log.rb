class RenameColumnsOfErrorReasonToLog < ActiveRecord::Migration
  def change
    rename_column :evaluations, :alive_error_reason, :alive_log
    rename_column :evaluations, :service_description_error_reason, :service_description_log
    rename_column :evaluations, :uri_subject_error_reason, :uri_subject_log
    rename_column :evaluations, :subject_is_uri_error_reason, :subject_is_uri_log
    rename_column :evaluations, :subject_is_http_uri_error_reason, :subject_is_http_uri_log
    rename_column :evaluations, :uri_provides_info_error_reason, :uri_provides_info_log
    rename_column :evaluations, :contains_links_error_reason, :contains_links_log
    rename_column :evaluations, :void_ttl_error_reason, :void_ttl_log
    rename_column :evaluations, :execution_time_error_reason, :execution_time_log
    rename_column :evaluations, :support_content_negotiation_error_reason, :support_content_negotiation_log
    rename_column :evaluations, :metadata_error_reason, :metadata_log
    rename_column :evaluations, :number_of_statements_error_reason, :number_of_statements_log
  end
end