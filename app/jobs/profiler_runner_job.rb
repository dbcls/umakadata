class ProfilerRunnerJob
  include Sidekiq::Worker

  sidekiq_options queue: :runner

  def perform
    date = Date.current.strftime('%Y%m')
    output_dir = Rails.root.join('tmp', 'triple_data_profiler', date)

    FileUtils.mkdir_p(output_dir)

    Endpoint.all.each do |ep|
      next unless ep.enabled && ep.profiler

      ProfilerJob.perform_async(ep.id, output_dir)
    end
  end
end
