redis_config = {
  url: "redis://#{ENV.fetch('SIDEKIQ_REDIS_HOST', 'localhost:6379')}/umakadata_#{Rails.env}",
}
redis_logger = if Rails.env.production?
                 Sidekiq::Logger.new('log/sidekiq_server.log', level: Logger::INFO)
               else
                 Sidekiq::Logger.new(STDOUT, level: Logger::DEBUG)
               end

Sidekiq.configure_server do |config|
  config.redis = redis_config
  config.logger = redis_logger
end

Sidekiq.configure_client do |config|
  config.redis = redis_config
  config.logger = redis_logger
end
