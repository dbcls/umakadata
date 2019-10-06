ActiveAdmin.register Endpoint do
  permit_params :name, :endpoint_url, :description_url, :disable_crawling,
                :viewer_url, :issue_id, :label_id

  config.sort_order = 'id_asc'

  index do
    selectable_column
    id_column
    column :name
    column 'Endpoint URL', :endpoint_url
    column 'Description URL', :description_url
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

    # column 'Viewer URL', :viewer_url
    # column 'Issue ID', :issue_id
    # column 'Label ID', :label_id

    actions
  end

  filter :name
  filter :endpoint_url
  filter :description_url
  filter :enabled

end
