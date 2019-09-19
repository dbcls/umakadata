module DatePicker
  extend ActiveSupport::Concern

  def date_picker
    {
      start: Crawl.oldest.started_at.to_date,
      end: (latest = Crawl.latest.started_at.to_date),
      current: begin
        Date.parse(params[:date])
      rescue
        latest
      end
    }
  end
end
