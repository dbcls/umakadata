require 'thor'

class Crawler < Thor
  desc 'run', 'run crawler'

  def execute(*id)
    require_relative '../../config/application'
    Rails.application.initialize!

    if (crawl = Crawl.find_by(started_at: Date.current.all_day))
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

  desc 'restart', 'restart incomplete crawling'

  def restart(*id)
    require_relative '../../config/application'
    Rails.application.initialize!

    unless Crawl.find_by(started_at: Date.current.all_day)
      say 'Crawling not exists.', %i[red bold]
      return
    end

    enqueued = Crawl.restart!(*id)

    say "Enqueue #{enqueued.size} #{'endpoint'.pluralize(enqueued.size)}."
    say enqueued.map { |x| "#{x.id} - #{x.name}" }.join("\n").indent(2)
  end

  map run: 'execute'
end
