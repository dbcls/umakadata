ActiveAdmin.register ExcludingGraph do
  menu priority: 3

  permit_params :uri, :endpoint_id

  config.sort_order = 'id_asc'

  endpoints = -> { Endpoint.all.order(:name) }

  index do
    selectable_column
    id_column
    column :endpoint
    column 'URI', :uri
    actions
  end

  filter :endpoint, as: :select, collection: endpoints
  filter :uri

  show do
    attributes_table do
      row :endpoint
      row :uri
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  csv do
    column :id
    column :endpoint_id
    column :uri
    column :created_at
    column :updated_at
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :endpoint, as: :select, collection: endpoints.call, include_blank: false
      input :uri, label: 'URI'
    end
    f.actions do
      add_create_another_checkbox
      action(:submit, label: 'Add Graph')
      cancel_link
    end
  end

  controller do
    def create
      super do |success, _|
        success.html do
          flash[:notice] = 'Excluding graph was successfully added.'
          redirect_to admin_excluding_graph_path(resource)
        end
      end
    end
  end
end
