Recaptcha.configure do |config|
  config.site_key = ENV['UMAKADATA_RECAPTCHA_SITE_KEY']
  config.secret_key = ENV['UMAKADATA_RECAPTCHA_SECRET_KEY']
end
