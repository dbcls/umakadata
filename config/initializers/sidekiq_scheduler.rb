require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  config.on(:startup) do
    Sidekiq.schedule = Rails.env.production? ? YAML.load_file(Rails.root.join('config', 'sidekiq_scheduler.yml')) : {}
    SidekiqScheduler::Scheduler.instance.reload_schedule!
  end

  SidekiqScheduler::Scheduler.instance.enabled = false if Rails.env.development?

  Rails.logger.info "SidekiqScheduler is #{SidekiqScheduler::Scheduler.instance.enabled ? 'enabled' : 'disabled'}."
end
