class CrawlerMailer < ApplicationMailer
  if (from = ENV['UMAKADATA_MAILER_CRAWL_MAILER_FROM'])
    default from: from
  end

  default subject: 'Crawler notification'

  def notify_finished_to(user, crawl)
    @user = user
    @crawl = crawl

    mail to: user.email
  end
end
