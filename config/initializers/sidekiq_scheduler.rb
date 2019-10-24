require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  if Rails.env.production? && ENV['UMAKADATA_DISABLE_CRAWLING'].blank?
    config.on(:startup) do
      Sidekiq.schedule = YAML.load_file(Rails.root.join('config', 'sidekiq_scheduler.yml'))
      SidekiqScheduler::Scheduler.instance.reload_schedule!
    end

    Rails.logger.info "Sidekiq schedule: #{Sidekiq.schedule}"
  else
    SidekiqScheduler::Scheduler.instance.enabled = false

    Rails.logger.info 'SidekiqScheduler is disabled.'
  end
end
