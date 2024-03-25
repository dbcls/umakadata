ActiveAdmin.register Endpoint do
  menu priority: 2

  permit_params :name, :endpoint_url, :description_url, :timeout, :enabled, :viewer_url, :issue_id, :label_id,
                resource_uris_attributes: %i[id uri allow deny regex case_insensitive created_at updated_at endpoint_id _destroy],
                graph_attributes: %i[id mode graphs endpoint_id created_at updated_at endpoint_id _destroy]

  config.sort_order = 'id_asc'

  index do
    selectable_column
    id_column
    column :name
    column 'Endpoint URL', :endpoint_url
    column 'Description URL', :description_url
    column :timeout
    column :enabled
    column :alert do |endpoint|
      if endpoint.just_registered?
        content_tag('span', style: 'color: #608F66;') do
          icon('fas', 'check fa', 'Just Registered')
        end
      elsif endpoint.dead?
        content_tag('span', style: 'color: #C04040;') do
          icon 'fas', 'skull-crossbones fa', 'Probably Dead'
        end
      end
    end
    column :latest_alive_date do |endpoint|
      endpoint.latest_alive_evaluation&.created_at
    end
    column :last_crawl_time do |endpoint|
      if (e = endpoint.latest_alive_evaluation)
        if (s = e.started_at) && (f = e.finished_at)
          Time.at(f - s).utc.strftime('%H:%M:%S')
        end
      end
    end

    actions
  end

  filter :name
  filter :endpoint_url
  filter :description_url
  filter :timeout
  filter :enabled

  batch_action :create_forum do |ids|
    message = 'The forums for endpoints have been created'

    batch_action_collection.find(ids).each do |endpoint|
      begin
        endpoint.create_forum
      rescue StandardError => e
        Rails.logger.error(e)
        message = e.message
      end
    end

    redirect_to collection_path, alert: message
  end

  show do
    attributes_table do
      row :name
      row :endpoint_url
      row :description_url
      row :timeout
      row :enabled
      row :viewer_url
      row :issue_id
      row :label_id
      row :created_at
      row :updated_at
    end

    panel 'List of Graphs' do
      table_for endpoint.graph do
        column :id do |x|
          link_to x.id, admin_graph_path(x)
        end
        column :mode
        column :graphs do |graph|
          simple_format(graph.graphs)
        end
        column :created_at
        column :updated_at
      end
    end

    panel 'List of Resource URI' do
      table_for endpoint.resource_uris do
        column :id do |x|
          link_to x.id, admin_resource_uri_path(x)
        end
        column :uri
        column :allow
        column :deny
        column :regex
        column :case_insensitive
        column :created_at
        column :updated_at
      end
    end

    panel 'List of Vocabulary Prefix' do
      table_for endpoint.vocabulary_prefixes do
        column :id
        column :uri
        column :created_at
        column :updated_at
      end
    end

    active_admin_comments
  end

  form do |f|
    f.semantic_errors

    f.inputs

    f.inputs 'Graphs', for: [:graph, f.object.graph || Graph.new] do |t|
      t.input :mode
      t.input :graphs
    end

    f.inputs do
      f.has_many :resource_uris, heading: 'List of Resource URI', allow_destroy: true do |t|
        t.input :uri, label: 'URI'
        t.input :allow
        t.input :deny
        t.input :regex
        t.input :case_insensitive
      end
    end

    f.actions
  end
end
