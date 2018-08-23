ActiveAdmin.register Prefix do

  permit_params :endpoint_id, :allowed_uri, :denied_uri, :case_sensitive

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

end
