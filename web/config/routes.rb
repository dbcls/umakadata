Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  root 'endpoints#top'

  get  'endpoints/search'
  get  'api/endpoints/search'  => 'api#endpoints_search'
  get  'endpoints/graph'
  get  'api/endpoints/graph'  => 'api#endpoints_graph'
  get  'endpoints/scores'
  get  'endpoints/:id(/:evaluation_id)/radar' => 'endpoints#radar'
  get  'endpoints/alive'
  get  'endpoints/service_descriptions'
  get  'endpoints/score_statistics'
  get  'endpoints/alive_statistics'
  get  'endpoints/service_description_statistics'
  get  'endpoints/:id(/:evaluation_id)/score_history' => 'endpoints#score_history'
  get  'endpoints/:id/:evaluation_id/log/:name' => 'endpoints#log'
  get  'endpoints/:id(/:evaluation_id)' => 'endpoints#show',  as: 'endpoint'

  get  'api/specifications' => 'api#specifications'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
