class CrawlerMailer < ApplicationMailer
  if (from = ENV['UMAKADATA_MAILER_CRAWL_MAILER_FROM'])
    default from: from
  end

  default subject: 'Crawler notification'

  def notify_finished_to(user, crawl)
    @user = user
    @crawl = crawl

    date = Time.current < Crawl.start_time(Date.current) ? Date.current : Date.current.succ
    @next_crawl = loop do
      crawl = Crawl.find_by(started_at: date.beginning_of_day..date.end_of_day)
      break Crawl.start_time(date) if !crawl || (crawl && !crawl.skip)
      date = date.succ
    end

    @measurement_with_exceptions = Measurement
                                     .where(started_at: @crawl.started_at..@crawl.finished_at)
                                     .where.not(exceptions: nil)

    mail to: user.email
  end
end
