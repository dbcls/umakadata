module DatePicker
  extend ActiveSupport::Concern

  def date_for_crawl
    {
      start: (oldest = Crawl.oldest) ? oldest.started_at.to_date : Date.current,
      end: (latest = Crawl.latest) ? latest.started_at.to_date : Date.current,
      current: begin
        Date.parse(params[:date])
      rescue
        latest.present? ? latest.started_at.to_date : Date.current
      end
    }
  end

  def date_for_endpoint(id)
    oldest = Evaluation
               .eager_load(:endpoint, :crawl)
               .where(endpoints: { id: id })
               .where.not(crawls: { finished_at: nil })
               .order('crawls.started_at')
               .first
               &.crawl

    latest = Evaluation
               .eager_load(:endpoint, :crawl)
               .where(endpoints: { id: id })
               .where.not(crawls: { finished_at: nil })
               .order('crawls.started_at')
               .last
               &.crawl

    {
      start: oldest.present? ? oldest.started_at.to_date : Date.current,
      end: latest.present? ? latest.started_at.to_date : Date.current,
      current: begin
        Date.parse(params[:date])
      rescue
        latest.present? ? latest.started_at.to_date : Date.current
      end
    }
  end
end
