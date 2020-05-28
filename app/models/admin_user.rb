class AdminUser < ApplicationRecord
  devise :database_authenticatable,
         :rememberable,
         :validatable

  validates :email, uniqueness: true

  class << self
    def crawl_post_hook(crawl)
      where(notification: true).each do |x|
        CrawlerMailer.notify_finished_to(x, crawl).deliver_later
      end
    end
  end
end
