require 'thor'

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

  map run: 'execute'
end
