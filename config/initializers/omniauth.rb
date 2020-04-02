Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Rails.application.credentials.github_oauth_client, Rails.application.credentials.github_oauth_secret, scope: 'repo'
end

OmniAuth.config.on_failure = Proc.new do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end
