class ProfilerRunnerJob
  include Sidekiq::Worker

  sidekiq_options queue: :runner

  def perform
    date = Date.current.strftime('%Y%m')

    Endpoint.all.each do |ep|
      next unless ep.enabled && ep.profiler

      ProfilerJob.perform_async(ep.id, Rails.root.join('tmp', 'triple_data_profiler', date))
    end
  end
end
