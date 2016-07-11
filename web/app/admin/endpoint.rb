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

  member_action :prefixes, method: [:get, :post] do
    if request.post?
      Prefix::import_csv(params)
      redirect_to "/admin/endpoints/#{params[:id]}/prefixes"
    else
      @endpoint_id = params[:id]
      render :prefixes
    end
  end


end
