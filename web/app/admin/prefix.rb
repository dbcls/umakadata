ActiveAdmin.register Prefix do

  permit_params :endpoint_id, :uri, :element_type

  index do
    selectable_column
    id_column
    column :endpoint
    column :uri
    column :element_type
    column :created_at
    column :updated_at
    actions
  end

  csv do
    column :id
    column :endpoint_id
    column :uri
    column :element_type
    column :created_at
    column :updated_at
  end

end
