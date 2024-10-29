class ProfilerJob
  include Sidekiq::Worker

  sidekiq_options queue: :profiler, retry: 0, backtrace: true

  def perform(endpoint_id, output_dir, wait: 50, timeout: 1000)
    @output_dir = output_dir

    ep = Endpoint.find(endpoint_id)

    logger.info("ep = #{endpoint_id}") { "Job performed for #{ep.attributes.slice('id', 'name', 'endpoint_url').to_json}" }

    cmd = [
      'java',
      '-jar',
      Rails.root.join('vendor', 'tripledataprofiler', 'TripleDataProfiler.jar'),
      '-ep',
      ep.endpoint_url,
      '-sbm',
      '-w',
      wait,
      '-timeout',
      timeout
    ]

    if (graph = ep.graph) && (list = graph.graph_list)
      opt = graph.mode == 'include' ? '-gn' : '-agn'
      list.each do |g|
        cmd.push(opt)
        cmd.push(g)
      end
    end

    logger.info("ep = #{endpoint_id}") { cmd.join(' ') }

    FileUtils.mkdir_p(output_dir)

    Zlib::GzipWriter.open(File.join(output_dir, "#{ep.id}.ttl.gz")) do |gz|
      Open3.popen3(*cmd.map(&:to_s)) do |stdin, stdout, stderr, _wait_thr|
        stdin.close
        stderr.close
        stdout.each do |line|
          gz.write line
        end
      end
    end

    logger.info("ep = #{endpoint_id}") { "Job finished" }
  rescue StandardError => e
    logger.error("ep = #{endpoint_id}") { Array(e.backtrace).unshift(e.message).join("\n") }
  end

  private

  def logger
    @logger ||= ActiveSupport::Logger.new(File.join(@output_dir, 'profile.log')).tap do |logger|
      logger.formatter = ::Logger::Formatter.new
    end
  end
end
