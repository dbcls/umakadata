class ProfilerRunnerJob
  include Sidekiq::Worker

  sidekiq_options queue: :runner

  def perform
    @output_dir = Rails.root.join('tmp', 'triple_data_profiler', Date.current.strftime('%Y%m'))

    FileUtils.mkdir_p(@output_dir)

    logger.info(self.class.name) { "Starting profiler" }

    Endpoint.where(enabled: true, profiler: true).order(:id).each do |ep|
      next unless ep.enabled && ep.profiler

      ProfilerJob.perform_async(ep.id, @output_dir.to_s)
      logger.info(self.class.name) { "Add profiler queue: ep = #{ep.id}" }
    end
  end

  private

  def logger
    @logger ||= ActiveSupport::Logger.new(@output_dir.join('profile.log')).tap do |logger|
      logger.formatter = ::Logger::Formatter.new
    end
  end
end
