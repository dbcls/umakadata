require 'thor'

module Umakadata
  module Tasks
    class Crawler < Thor
      desc 'run', 'run crawler'

      def execute(*id)
        require_relative '../../config/application'
        Rails.application.initialize!

        if (crawl = Crawl.on(Date.current))
          unless crawl.finished?
            say 'Crawling already in progress.', %i[red bold]
            return
          end

          if yes? 'Crawling for current date is already exist. Remove and start new crawler? [y/n]: ', %i[red bold]
            crawl.destroy
          else
            say 'Aborted.', :red
            return
          end
        end

        Crawl.start!(*id)
      end

      desc 'set', 'set crawl activity'
      method_option :active, type: :boolean

      def set(date)
        require_relative '../../config/application'
        Rails.application.initialize!

        date = Date.parse(date)

        raise ArgumentError, 'Past date' if date < Date.current
        raise ArgumentError, 'Already started' if date == Date.current && Crawl.start_time(date) <= Time.current

        crawl_time = Crawl.start_time(date).to_formatted_s

        return unless yes? "#{options[:active] == false ? 'Disable' : 'Enable'} crawl on #{crawl_time} ? [y/n]:", :bold

        if options[:active] == false
          Crawl.create!(started_at: Crawl.start_time(date)) unless Crawl.on(date)
          Crawl.on(date)&.update!(skip: true)
        else
          Crawl.skipped.on(date)&.destroy!
        end
      end

      map run: 'execute'
    end
  end
end
