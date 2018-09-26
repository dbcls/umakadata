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
    f.inputs
    f.actions do
      add_create_another_checkbox
      action(:submit, label: 'Add Prefix')
      cancel_link
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
