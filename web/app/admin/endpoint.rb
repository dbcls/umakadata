require "nkf"

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
    permitted = [:name, :url]
  end

  show do
    panel "Endpoint Details" do
      attributes_table_for endpoint do
        row :id
        row :name
        row :url
        row :created_at
        row :updated_at
        row :issue_id
        row :prefixes do
          link_to 'import prefixes data from CSV file', "/admin/endpoints/#{endpoint.id}/prefixes"
        end
      end
    end
    active_admin_comments
  end

  member_action :prefixes, method: [:get, :post] do

    if request.post?
      if params[:endpoint].nil?
        redirect_to "/admin/endpoints/#{params[:id]}/prefixes", alert: "element_type and CSV file are required"
        return
      end
      if params[:endpoint][:element_type].nil?
        redirect_to "/admin/endpoints/#{params[:id]}/prefixes", alert: "element_type required"
        return
      end
      if params[:endpoint][:file].nil?
        redirect_to "/admin/endpoints/#{params[:id]}/prefixes", alert: "CSV file required"
        return
      end
      CSV.parse(params[:endpoint][:file].read, {headers: true}).each do |row|
        unless NKF::nkf("-w", row[0].to_s) =~ URI::regexp
          redirect_to "/admin/endpoints/#{params[:id]}/prefixes", alert: "CSV file contains invalid URI"
          return
        end
      end
      Prefix::import_csv(params)
      redirect_to "/admin/endpoints/#{params[:id]}/prefixes", notice: "CSV imported successfully!"
    else
      @endpoint_id = params[:id]
      render :prefixes
    end
  end


end
