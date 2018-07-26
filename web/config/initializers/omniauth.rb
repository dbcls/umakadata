Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, Rails.application.secrets.github_oauth_client, Rails.application.secrets.github_oauth_secret, :scope => 'public_repo'
end

OmniAuth.config.on_failure = Proc.new { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}