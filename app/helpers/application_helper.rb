module ApplicationHelper
  def metrics
    recent = Crawl.order(started_at: :desc).limit(8).to_a

    return Hash.new { { count: 0, variation: 0 } } if recent.size < 2

    recent.shift unless (latest_finished = recent.first.finished?)
    latest = recent.first
    previous = recent[1]
    earliest = recent.last

    aee = earliest.evaluations.where('evaluations.alive': true).count
    {
      data_collection: {
        count: Crawl.count - (latest_finished ? 0 : 1),
        variation: format('%d', (Time.current - latest.started_at) / 3600 / 24)
      },
      no_of_endpoints: {
        count: (ne = latest.evaluations.count),
        variation: ne - (nee = earliest.evaluations.count)
      },
      active_endpoints: {
        count: (ae = latest.evaluations.where('evaluations.alive': true).count),
        variation: ae - previous.evaluations.where('evaluations.alive': true).count
      },
      alive_rates: {
        count: (ar = (ne.positive? ? (ae / ne.to_f) : 0) * 100).round(0),
        variation: (ar - (nee.positive? ? (aee / nee.to_f) : 0) * 100).round(0)
      },
      data_entries: {
        count: (v = latest.evaluations.map(&:data_entry).compact.sum),
        variation: v - previous.evaluations.map(&:data_entry).compact.sum
      }
    }
  end
end
