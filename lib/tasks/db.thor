require 'thor'

module Umakadata
  module Tasks
    class Db < Thor
      desc 'archive', 'archive old data'

      def archive
        initialize_app

        backup_dir = ENV.fetch('UMAKADATA_DATABASE_BACKUP_DIR')

        loop do
          crawl = Measurement.order(:started_at).first.evaluation.crawl

          break if (from = crawl.started_at.beginning_of_month) >= Date.current.beginning_of_month.ago(1.year)
          to = from.end_of_month

          title = "#{from.year}-#{from.month}"

          file = File.join(backup_dir, "measurements-#{title}.tsv.gz")
          warn("Copying records to #{file}")
          sql = <<~SQL
            COPY (#{Measurement.where(evaluation_id: Evaluation.where(crawl_id: Crawl.where(started_at: from..to))).to_sql})
              TO PROGRAM 'gzip > #{file} && chmod 644 #{file}'
          SQL
          ActiveRecord::Base.connection.execute sql

          file = File.join(backup_dir, "activities-#{title}.tsv.gz")
          warn("Copying records to #{file}")
          sql = <<~SQL
            COPY (#{Activity.where(measurement_id: Measurement.where(evaluation_id: Evaluation.where(crawl_id: Crawl.where(started_at: from..to)))).to_sql})
              TO PROGRAM 'gzip > #{file} && chmod 644 #{file}'
          SQL
          ActiveRecord::Base.connection.execute sql

          warn("Deleting archived records")
          Measurement.where(evaluation_id: Evaluation.where(crawl_id: Crawl.where(started_at: from..to))).destroy!
        end
      end

      private

      def initialize_app
        require_relative '../../config/application'
        Rails.application.initialize!
      end
    end
  end
end
