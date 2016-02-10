class Evaluation < ActiveRecord::Base

  def self.record(endpoint, retriever)
    self.transaction do
      self.where(endpoint_id: endpoint.id).update_all("latest = false")
      self.record_new endpoint, retriever
    end
  end

  def self.record_new(endpoint, retriever)
    eval = Evaluation.new
    eval.endpoint_id         = endpoint.id

    eval.latest              = true

    eval.alive               = retriever.alive?
    eval.service_description = retriever.service_description
    eval.void_uri            = retriever.well_known_uri
    eval.void_ttl            = retriever.void_on_well_known_uri

    eval.subject_is_uri      = retriever.uri_subject?
    eval.subject_is_http_uri = retriever.http_subject?
    eval.uri_provides_info   = retriever.uri_provides_info?
    eval.contains_links      = retriever.contains_links?

    eval.score               = Evaluation.calc_score(eval)
    eval.rank                = Evaluation.calc_rank(eval.score)

    eval.save!
  end

  def self.calc_score(eval)
    score = 0

    score += 15 if eval.alive

    score += 15 if eval.service_description

    count = 0
    count += 1 if eval.subject_is_uri
    count += 1 if eval.subject_is_http_uri
    count += 1 if eval.uri_provides_info
    count += 1 if eval.contains_links
    score += (count / 4.0 * 100) / 4

    score += 25 if eval.void_ttl.nil?
    return score
  end

  def self.calc_rank(score)
    return case
    when  0 <= score && score < 30 then 1
    when 30 <= score && score < 50 then 2
    when 50 <= score && score < 70 then 3
    when 70 <= score && score < 85 then 4
    when 85 <= score               then 5
    end
  end

end
