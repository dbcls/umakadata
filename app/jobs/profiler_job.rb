class ProfilerJob
  include Sidekiq::Worker

  sidekiq_options queue: :profiler, retry: 0, backtrace: true

  def perform(endpoint_id, output_dir, wait: 50, timeout: 1000)
    ep = Endpoint.find(endpoint_id)

    logger.info("id: #{endpoint_id}") { "Job performed for #{ep.attributes.slice('id', 'name', 'endpoint_url').to_json}" }

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

    logger.info("id: #{endpoint_id}") { cmd.join(' ') }

    Zlib::GzipWriter.open(File.join(output_dir, "#{ep.id}.ttl.gz")) do |gz|
      Open3.popen3(*cmd.map(&:to_s)) do |stdin, stdout, stderr, _wait_thr|
        stdin.close
        stderr.close
        stdout.each do |line|
          gz.write line
        end
      end
    end
  rescue StandardError => e
    logger.error("id: #{endpoint_id}") { e }
  end

  private

  LOG_FILE = Rails.root.join('log', 'profile.log')

  def logger
    @logger ||= ActiveSupport::Logger.new(LOG_FILE, 5, 10 * 1024 * 1024).tap do |logger|
      logger.formatter = ::Logger::Formatter.new
    end
  end
end
