ActiveAdmin.register Endpoint do
  menu priority: 2

  permit_params :name, :endpoint_url, :description_url, :enabled,
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
    column :last_crawl_time do |endpoint|
      if (e = endpoint.latest_alive_evaluation)
        if (s = e.started_at) && (f = e.finished_at)
          Time.at(f - s).utc.strftime('%H:%M:%S')
        end
      end
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

  controller do
    def after_modification(succeeded)
      if succeeded
        if @endpoint.errors.any?
          flash[:warning] = @endpoint.errors.full_messages.join('<br>').html_safe
        end
        redirect_to admin_endpoint_path(id: @endpoint.id)
      else
        flash.now[:error] = @endpoint.errors.full_messages.join('<br>').html_safe
        @endpoint = Endpoint.new(permitted_params[:endpoint])
        render :new
      end
    end

    def create_issue(endpoint)
      begin
        label = endpoint.create_label
        issue = endpoint.create_issue
        GithubHelper.add_labels_to_an_issue(issue[:number], [label[:name]])
        GithubHelper.add_labels_to_an_issue(endpoint.issue_id, ['endpoints'])
      rescue => e
        errors.add(:base, "Error occured during using Github API!\n\n#{e.message}")
      end
    end

    def create
      @endpoint = Endpoint.new(permitted_params[:endpoint])
      create_issue(@endpoint)
      after_modification(@endpoint.save)
    end

    def update
      @endpoint = Endpoint.find(permitted_params[:id])
      after_modification(@endpoint.update(permitted_params[:endpoint]))
    end
  end

  batch_action :create_label do |ids|
    message = 'The endpoints have created labels'
    batch_action_collection.find(ids).each do |endpoint|
      begin
        label = Endpoint.create_label(endpoint)
        next if endpoint.issue_id.nil?
        GithubHelper.add_labels_to_an_issue(endpoint.issue_id, [label[:name], 'endpoints']) unless label.nil?
      rescue => e
        message = e.message
      end
    end
    redirect_to collection_path, alert: message
  end

  batch_action :create_issue do |ids|
    message = 'The endpoints have created issues'
    batch_action_collection.find(ids).each do |endpoint|
      begin
        Endpoint.create_issue(endpoint)
        GithubHelper.add_labels_to_an_issue(endpoint.issue_id, ['endpoints'])
      rescue => e
        message = e.message
      end
    end
    redirect_to collection_path, alert: message
  end

  batch_action :sync_label do |ids|
    message = 'The endpoints have synchronized label for issue'
    batch_action_collection.find(ids).each do |endpoint|
      begin
        Endpoint.sync_label(endpoint)
      rescue => e
        message = e.message
      end
    end
    redirect_to collection_path, alert: message
  end
end
