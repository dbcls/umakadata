crawls = (@from..@to).map { |d| Crawl.finished.on(d) }
evaluations = crawls.map { |c| c&.evaluations || [] }

json.rank do
  json.labels (@from..@to).map { |d| d.strftime('%m/%d') }
  json.datasets do
    list = ('A'..'E').to_a.reverse.map do |rank|
      {
        label: "Rank #{rank}",
        data: evaluations.map { |x| x.filter { |y| y.rank == Evaluation.rank_number(rank) }.count },
      }
    end

    json.array! list
  end
end

json.score do
  json.labels (@from..@to).map { |d| d.strftime('%m/%d') }
  json.datasets do
    list = [{
              label: 'Average',
              data: crawls.map { |c| c&.score_average&.to_i || 0 },
              lineTension: 0,
            },
            {
              label: 'Median',
              data: crawls.map { |c| c&.score_median&.round(0) || 0 },
              lineTension: 0,
            }]

    json.array! list
  end
end

json.population do
  json.labels (@from..@to).map { |d| d.strftime('%m/%d') }
  json.datasets do
    list = [{
              label: 'Alive (%)',
              data: crawls.map { |c| ((c&.alive_rate || 0) * 100).to_i },
              lineTension: 0,
            },
            {
              label: 'ServiceDescription (%)',
              data: crawls.map { |c| ((c&.service_descriptions_rate || 0) * 100).to_i },
              lineTension: 0,
            },
            {
              label: 'VoID (%)',
              data: crawls.map { |c| ((c&.void_rate || 0) * 100).to_i },
              lineTension: 0,
            }]

    json.array! list
  end
end

json.options do
  json.rank do
    json.max ((evaluations.map { |x| x.count }.max.to_f / 10).ceil * 10).to_i
  end
end
