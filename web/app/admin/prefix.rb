ActiveAdmin.register Prefix do

  permit_params :endpoint_id, :allow, :deny, :as_regex, :case_insensitive, :use_fixed_uri, :fixed_uri

  index do
    selectable_column
    id_column
    column :endpoint
    column :allow
    column :deny
    column :as_regex
    column :case_insensitive
    column 'Use Fixed URI', :use_fixed_uri
    column 'Fixed URI', :fixed_uri
    column :created_at
    column :updated_at
    actions
  end

  show do
    attributes_table do
      row :endpoint
      row :allow
      row :deny
      row :as_regex
      row :case_insensitive
      row :use_fixed_uri
      row :fixed_uri
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  csv do
    column :id
    column :endpoint_id
    column :allow
    column :deny
    column :as_regex
    column :case_insensitive
    column :use_fixed_uri
    column :fixed_uri
    column :created_at
    column :updated_at
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :endpoint
      input :allow
      input :deny
      input :as_regex
      input :case_insensitive
      input :use_fixed_uri, label: "Use fixed URI"
      input :fixed_uri, label: "Fixed URI"
    end
    f.actions do
      add_create_another_checkbox
      action(:submit, label: 'Add Prefix')
      cancel_link
    end
    script do
      raw <<-SCRIPT
        $(function() {
          var update_form;
          update_form = function() {
            var as_regex, use_fixed_uri;
            as_regex = $('#prefix_as_regex').prop('checked');
            use_fixed_uri = $('#prefix_use_fixed_uri').prop('checked');
            $('#prefix_allow').prop('disabled', use_fixed_uri);
            $('#prefix_deny').prop('disabled', use_fixed_uri);
            $('#prefix_as_regex').prop('disabled', use_fixed_uri);
            $('#prefix_case_insensitive').prop('disabled', !as_regex || use_fixed_uri);
            $('#prefix_fixed_uri').prop('disabled', !use_fixed_uri);
          };
          update_form();
          $('#prefix_as_regex').on('change', function() {
            update_form();
          });
          $('#prefix_use_fixed_uri').on('change', function() {
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
          redirect_to admin_prefix_path(resource)
        end
      end
    end
  end
end
