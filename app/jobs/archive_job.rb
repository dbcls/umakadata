class ArchiveJob
  include Sidekiq::Worker

  sidekiq_options queue: :runner

  def perform
    backup_dir = ENV.fetch('UMAKADATA_DATABASE_BACKUP_DIR')

    loop do
      break unless (crawl = Measurement.order(:started_at).first&.evaluation&.crawl)
      break if (from = crawl.started_at.beginning_of_month) >= Date.current.beginning_of_month.ago(1.year)

      to = from.end_of_month
      evaluations = Evaluation.where(crawl_id: Crawl.where(started_at: from..to))
      measurements = Measurement.where(evaluation_id: evaluations)

      title = "#{from.year}-#{from.month}"

      file = File.join(backup_dir, "measurements-#{title}.tsv.gz")
      warn("Copying records to #{file}")
      sql = <<~SQL
        COPY (#{Measurement.where(evaluation_id: evaluations).to_sql})
          TO PROGRAM 'gzip > #{file} && chmod 644 #{file}'
      SQL
      ActiveRecord::Base.connection.execute sql

      file = File.join(backup_dir, "activities-#{title}.tsv.gz")
      warn("Copying records to #{file}")
      sql = <<~SQL
        COPY (#{Activity.where(measurement_id: measurements).to_sql})
          TO PROGRAM 'gzip > #{file} && chmod 644 #{file}'
      SQL
      ActiveRecord::Base.connection.execute sql

      warn("Deleting archived records")
      Activity.where(measurement_id: measurements).delete_all
      Measurement.where(evaluation_id: evaluations).delete_all
    end

    warn("No more records to archive")
  end
end
