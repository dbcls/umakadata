json.date @date

json.data do
  json.array! @evaluations.preload(:endpoint).order(:endpoint_id) do |evaluation|
    json.extract! evaluation.endpoint, :id, :name, :endpoint_url
    json.extract! evaluation, :score, :alive, :service_description
    json.rank evaluation.rank_label
  end
end
