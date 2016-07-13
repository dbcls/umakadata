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

end
