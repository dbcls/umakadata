module RootHelper
  def metrics
    recent = Crawl.where.not(finished_at: nil).order(started_at: :desc).limit(8).to_a

    return Hash.new { { count: 0, variation: 0 } } if recent.size < 2

    latest = recent.shift
    yesterday = recent.shift
    last_week = recent.find { |x| x.started_at.to_date <= 7.days.ago(Date.current) }

    aee = last_week.evaluations.where('evaluations.alive': true).count
    {
      data_collection: {
        count: Crawl.where.not(finished_at: nil).count,
        diff: format('%d', (Time.current - latest.finished_at) / 1.day)
      },
      no_of_endpoints: {
        count: (ne = latest.evaluations.count),
        diff: ne - (nee = last_week.evaluations.count)
      },
      active_endpoints: {
        count: (ae = latest.evaluations.where(alive: true).count),
        diff: ae - yesterday.evaluations.where(alive: true).count
      },
      alive_rates: {
        count: (ar = (ne.positive? ? (ae / ne.to_f) : 0) * 100).round(0),
        diff: (ar - (nee.positive? ? (aee / nee.to_f) : 0) * 100).round(0)
      },
      data_entries: {
        count: (v = latest.evaluations.map(&:data_entry).compact.sum),
        diff: v - yesterday.evaluations.map(&:data_entry).compact.sum
      }
    }
  end
end
