json.array! @endpoints do |endpoint|
  json.extract! endpoint, :id, :name, :endpoint_url, :description_url
  json.evaluation do
    json.started_at endpoint.evaluations.first.created_at
    json.rank endpoint.evaluations.first.rank_label
    json.extract! endpoint.evaluations.first, :score, :publisher, :license, :language, :service_keyword,
                  :graph_keyword, :data_scale, :cors, :alive, :alive_rate, :last_updated,
                  :service_description, :void, :metadata, :ontology, :links_to_other_datasets, :data_entry,
                  :support_html_format, :support_rdfxml_format, :support_turtle_format, :cool_uri, :http_uri,
                  :provide_useful_information, :link_to_other_uri, :execution_time
  end
end
