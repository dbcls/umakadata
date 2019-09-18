json.date @date

json.data do
  json.array! @crawl.evaluations.order(:endpoint_id) do |evaluation|
    json.extract! evaluation.endpoint, :id, :name, :endpoint_url
    json.extract! evaluation, :score
    json.rank evaluation.rank_label
  end
end
