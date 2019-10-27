ActiveAdmin.register DatasetRelation do
  menu priority: 4

  permit_params :src_endpoint_id, :dst_endpoint_id, :relation, :endpoint_id

  config.sort_order = 'id_asc'

  endpoints = -> { Endpoint.all.order(:name).pluck(:name, :id).to_h }

  index do
    selectable_column
    id_column
    column :endpoint
    column :src_endpoint do |x|
      if (endpoint = Endpoint.find_by(id: x.src_endpoint_id))
        link_to endpoint.name, admin_endpoint_path(x.src_endpoint_id)
      end
    end
    column :dst_endpoint do |x|
      if (endpoint = Endpoint.find_by(id: x.dst_endpoint_id))
        link_to endpoint.name, admin_endpoint_path(x.dst_endpoint_id)
      end
    end

    actions
  end

  filter :endpoint
  filter :src_endpoint_id, label: 'src endpoint', as: :select, collection: endpoints
  filter :dst_endpoint_id, label: 'dst endpoint', as: :select, collection: endpoints

  show do
    attributes_table do
      row :endpoint
      row :src_endpoint do |x|
        if (endpoint = Endpoint.find_by(id: x.src_endpoint_id))
          link_to endpoint.name, admin_endpoint_path(x.src_endpoint_id)
        end
      end
      row :dst_endpoint do |x|
        if (endpoint = Endpoint.find_by(id: x.dst_endpoint_id))
          link_to endpoint.name, admin_endpoint_path(x.dst_endpoint_id)
        end
      end
    end
    active_admin_comments
  end

  form do |f|
    f.semantic_errors
    f.inputs do
      input :endpoint
      input :src_endpoint_id, as: :select, collection: endpoints, include_blank: false
      input :dst_endpoint_id, as: :select, collection: endpoints, include_blank: false
    end
    f.actions do
      add_create_another_checkbox
      action(:submit, label: 'Add Dataset Relation')
      cancel_link
    end
  end

  controller do
    def create
      super do |success, _|
        success.html do
          flash[:notice] = 'Dataset Relation was successfully added.'
          redirect_to admin_dataset_relation_path(resource)
        end
      end
    end
  end
end
