ActiveAdmin.register ResourceURI do
  menu priority: 3

  permit_params :uri, :as_regex, :allow, :deny, :case_insensitive, :endpoint_id

  config.sort_order = 'id_asc'

  index do
    selectable_column
    id_column
    column :endpoint
    column 'URI', :uri
    column :allow
    column :deny
    column :regex
    column :case_insensitive
    actions
  end

  filter :endpoint
  filter :uri
  filter :allow
  filter :deny
  filter :regex
  filter :case_insensitive

  show do
    attributes_table do
      row :endpoint
      row :uri
      row :allow
      row :deny
      row :regex
      row :case_insensitive
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  csv do
    column :id
    column :endpoint_id
    column :uri
    column :allow
    column :deny
    column :regex
    column :case_insensitive
    column :created_at
    column :updated_at
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :endpoint
      input :uri, label: 'URI'
      input :allow
      input :deny
      input :regex
      input :case_insensitive
    end
    f.actions do
      add_create_another_checkbox
      action(:submit, label: 'Add Prefix')
      cancel_link
    end
    script do
      raw <<-SCRIPT
        $(function() {
          let update_form = function() {
            let regex = $('#resource_uri_regex').prop('checked');
            $('#resource_uri_case_insensitive').prop('disabled', !regex);
          };
          update_form();
          $('#resource_uri_regex').on('change', function() {
            update_form();
          });
        });
      SCRIPT
    end
  end

  controller do
    def create
      super do |success, _|
        success.html do
          flash[:notice] = 'Prefix was successfully added.'
          redirect_to admin_resource_uri_path(resource)
        end
      end
    end
  end
end
