require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do
  root 'root#dashboard'

  get '/about', to: 'root#about'
  get '/inquiries', to: 'root#inquiry'
  post '/inquiries', to: 'root#send_inquiry'
  get '/terms', to: 'root#terms'
  get '/api', to: 'root#api'

  get '/endpoint', to: 'endpoint#index', as: :endpoint_index
  get '/endpoint/search'
  get '/endpoint/statistics'
  get '/endpoint/graph'
  get '/endpoint/:id', to: 'endpoint#show', as: :endpoint
  get '/endpoint/:id/scores', to: 'endpoint#scores', as: :endpoint_scores
  get '/endpoint/:id/histories', to: 'endpoint#histories', as: :endpoint_histories
  get '/endpoint/:id/log/:name', to: 'endpoint#log', as: :endpoint_log
  post '/endpoint/:id/forum', to: 'endpoint#create_forum', as: :endpoint_create_forum

  get '/api/endpoint/search', to: 'endpoint#search', defaults: { format: 'json' }
  get '/api/excluding_graph', to: 'excluding_graph#index', defaults: { format: 'json' }
  get '/api/resource_uri/search', to: 'resource_uri#search', defaults: { format: 'json' }

  get '/auth/:provider/callback', to: 'session#callback'
  get '/auth/after_authorization', to: 'session#after_authorization'
  get '/auth/failure', to: 'session#failure'

  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  if ENV['SIDEKIQ_USER'].present? && ENV['SIDEKIQ_PASSWORD'].present?
    Sidekiq::Web.use Rack::Auth::Basic do |username, password|
      ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_USER'])) &
        ActiveSupport::SecurityUtils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV['SIDEKIQ_PASSWORD']))
    end
  end

  mount Sidekiq::Web, at: '/sidekiq'
end
