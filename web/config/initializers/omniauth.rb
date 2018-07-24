Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Rails.application.secrets.github_client_id, Rails.application.secrets.github_client_secret, :scope => 'public_repo'
end