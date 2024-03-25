include TruncateBytes

ActiveAdmin.register Graph do
  menu priority: 3

  permit_params :mode, :graphs, :endpoint_id

  config.sort_order = 'id_asc'

  endpoints = -> { Endpoint.all.order(:name) }

  index do
    selectable_column
    column :endpoint
    column :mode
    column '# of graphs' do |graph|
      graph.graph_list&.size
    end
    column :graphs do |graph|
      graph.graph_list.present? ? truncate_bytes(graph.graph_list.inspect, 150) : nil
    end
    actions
  end

  filter :endpoint, as: :select, collection: endpoints

  show do
    attributes_table do
      row :endpoint
      row :mode
      row :graphs do |graph|
        simple_format(graph.graphs)
      end
      row :created_at
      row :updated_at
    end
    active_admin_comments
  end

  csv do
    column :id
    column :endpoint_id
    column :mode
    column :graphs
    column :created_at
    column :updated_at
  end

  form do |f|
    f.semantic_errors
    f.inputs
    f.actions
  end
end
