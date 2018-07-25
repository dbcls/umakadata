ActiveAdmin.register Endpoint do

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if resource.something?
#   permitted
# end

  permit_params do
    permitted = [:name, :url, :description_url, :disable_crawling, :viewer_url]
  end

  scope 'All', :all, :default => true
  scope :disable_crawling do |endpoints|
    endpoints.where(:disable_crawling => true)
  end

  filter :name
  filter :url
  filter :disable_crawling
  filter :created_at
  filter :updated_at

  index do
    selectable_column
    id_column
    column :name
    column :url
    column :issue_id do |endpoint|
      issue_id = endpoint.issue_id
      if issue_id.nil?
        "N/A"
      else
        issue_id
      end
    end
    column :label_id do |endpoint|
      label_id = endpoint.label_id
      if label_id.nil?
        "N/A"
      else
        label_id
      end
    end
    column :disable_crawling
    column :latest_alive_date do |endpoint|
      latest = endpoint.evaluations.where(:alive => true).last
      if latest.nil?
        "N/A"
      else
        latest.retrieved_at.to_formatted_s(:long)
      end
    end
    column :alarm do |endpoint|
      latest = endpoint.evaluations.where(:alive => true).last
      if latest.nil?
        "Not Evaluated"
      elsif latest.retrieved_at < 1.month.ago
        "Probably Dead"
      end
    end
    actions
  end

  show do
    panel "Endpoint Details" do
      attributes_table_for endpoint do
        row :id
        row :name
        row :url
        row :description_url
        row :viewer_url
        row :disable_crawling
        row :created_at
        row :updated_at
        row :issue_id
        row :label_id
        row :prefixes do
          link_to 'import prefixes data from CSV file', "/admin/endpoints/#{endpoint.id}/prefixes"
        end
      end
    end
    active_admin_comments
  end

  controller do
    def create
      @endpoint = Endpoint.new(permitted_params[:endpoint])
      @endpoint.save
      if @endpoint.errors.any?
        flash.now[:error] = @endpoint.errors.full_messages.join('<br>').html_safe
        @endpoint = Endpoint.new(permitted_params[:endpoint])
        render :new
      else
        redirect_to "/admin/endpoints/#{@endpoint.id}"
      end
    end
  end

  member_action :prefixes, method: [:get, :post] do
    if request.post?
      message = Prefix::validates_params(params)
      unless message.nil?
        redirect_to "/admin/endpoints/#{params[:id]}/prefixes", alert: message
      else
        error = Prefix::import_csv(params)
        unless error.nil?
          redirect_to "/admin/endpoints/#{params[:id]}/prefixes", alert: error
        else
          redirect_to "/admin/endpoints/#{params[:id]}/prefixes", notice: "CSV imported successfully!"
        end
      end
    else
      @endpoint_id = params[:id]
      render :prefixes
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
end
