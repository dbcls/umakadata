Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Rails.application.secrets.github_oauth_client, Rails.application.secrets.github_oauth_secret, scope: 'repo'
end

OmniAuth.config.on_failure = Proc.new do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end
