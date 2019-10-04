require 'sidekiq'
require 'sidekiq-scheduler'

Sidekiq.configure_server do |config|
  if Rails.env.production? && ENV['UMAKADATA_DISABLE_CRAWLING'].blank?
    config.on(:startup) do
      Sidekiq.schedule = YAML.load_file(Rails.root.join('config', 'sidekiq_scheduler.yml'))
      SidekiqScheduler::Scheduler.instance.reload_schedule!
    end
  else
    SidekiqScheduler::Scheduler.instance.enabled = false
  end

  Rails.logger.info "SidekiqScheduler is #{SidekiqScheduler::Scheduler.instance.enabled ? 'enabled' : 'disabled'}."
end
