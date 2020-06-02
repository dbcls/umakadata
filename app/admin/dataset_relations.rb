ActiveAdmin.register DatasetRelation do
  menu priority: 4

  permit_params :src_endpoint_id, :dst_endpoint_id, :relation, :endpoint_id

  config.sort_order = 'id_asc'

  endpoints = -> { Endpoint.all.order(:id) }
  endpoint_label = ->(endpoint) { "#{endpoint.id} - #{endpoint.name}" }

  active_admin_import validate: true,
                      batch_transaction: true,
                      headers_rewrites: {
                        'Id': 'id',
                        'Endpoint': 'endpoint_id',
                        'Src endpoint': 'src_endpoint_id',
                        'Dst endpoint': 'dst_endpoint_id',
                        'Relation': 'relation'
                      },
                      before_batch_import: lambda { |importer|
                        DatasetRelation.where(id: importer.values_at('id')).delete_all
                      },
                      template_object: ActiveAdminImport::Model.new(
                        hint: 'The headers of CSV should not be modified as download at index page or '\
                              'should be "id","endpoint_id","src_endpoint_id","dst_endpoint_id","relation"'
                      )

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

  csv do
    column :id
    column :endpoint_id
    column :src_endpoint_id
    column :dst_endpoint_id
    column :relation
  end

  filter :endpoint, as: :select, collection: endpoints, member_label: endpoint_label
  filter :src_endpoint_id, label: 'src endpoint', as: :select, collection: endpoints, member_label: endpoint_label
  filter :dst_endpoint_id, label: 'dst endpoint', as: :select, collection: endpoints, member_label: endpoint_label

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
      f.input :endpoint, member_label: endpoint_label, include_blank: false
      f.input :src_endpoint_id, as: :select, collection: endpoints.call, member_label: endpoint_label, include_blank: false
      f.input :dst_endpoint_id, as: :select, collection: endpoints.call, member_label: endpoint_label, include_blank: false
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
