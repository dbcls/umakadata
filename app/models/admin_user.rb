class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :rememberable,
         :validatable

  class << self
    def crawl_post_hook(crawl)
      where(notification: true).each do |x|
        CrawlerMailer.notify_finished_to(x, crawl).deliver_later
      end
    end
  end
end
