ActiveAdmin.register Prefix do

  permit_params :endpoint_id, :allow_regex, :deny_regex, :case_sensitive

  index do
    selectable_column
    id_column
    column :endpoint
    column :allow_regex
    column :deny_regex
    column :case_sensitive
    column :created_at
    column :updated_at
    actions
  end

  csv do
    column :id
    column :endpoint_id
    column :allow_regex
    column :deny_regex
    column :case_sensitive
    column :created_at
    column :updated_at
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
