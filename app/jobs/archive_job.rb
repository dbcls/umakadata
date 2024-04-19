class ArchiveJob
  include Sidekiq::Worker

  sidekiq_options queue: :archiver

  def perform
    backup_dir = ENV.fetch('UMAKADATA_DATABASE_BACKUP_DIR')

    loop do
      break unless (crawl = Measurement.order(:started_at).first&.evaluation&.crawl)
      break if (from = crawl.started_at.beginning_of_month) >= Date.current.beginning_of_month.ago(1.year)

      to = from.end_of_month
      evaluations = Evaluation.where(crawl_id: Crawl.where(started_at: from..to))
      measurements = Measurement.where(evaluation_id: evaluations)

      title = "#{from.year}-#{from.month}"
      logger.info('ArchiveJob') { "Start archiving #{title}" }

      file = File.join(backup_dir, "measurements-#{title}.tsv.gz")
      logger.info('ArchiveJob') { "Copying records to #{file}" }
      sql = <<~SQL
        COPY (#{Measurement.where(evaluation_id: evaluations).to_sql})
          TO PROGRAM 'gzip > #{file} && chmod 644 #{file}'
      SQL
      ActiveRecord::Base.connection.execute sql

      file = File.join(backup_dir, "activities-#{title}.tsv.gz")
      logger.info('ArchiveJob') { "Copying records to #{file}" }
      sql = <<~SQL
        COPY (#{Activity.where(measurement_id: measurements).to_sql})
          TO PROGRAM 'gzip > #{file} && chmod 644 #{file}'
      SQL
      ActiveRecord::Base.connection.execute sql

      logger.info('ArchiveJob') { 'Deleting archived records' }
      Activity.where(measurement_id: measurements).delete_all
      Measurement.where(evaluation_id: evaluations).delete_all

      logger.info('ArchiveJob') { 'Vacuuming' }
      ActiveRecord::Base.connection.execute 'VACUUM FULL ANALYSE;'
    end

    logger.info('ArchiveJob') { 'No more records to archive' }
  end

  private

  LOG_FILE = Rails.root.join('log', 'archive.log')

  def logger
    @logger ||= ActiveSupport::Logger.new(LOG_FILE, 5, 10 * 1024 * 1024).tap do |logger|
      logger.formatter = ::Logger::Formatter.new
    end
  end
end
