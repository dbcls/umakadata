class Evaluation < ActiveRecord::Base

  belongs_to :endpoint

  def self.record(endpoint, retriever)
    self.transaction do
      self.where(endpoint_id: endpoint.id).update_all("latest = false")
      self.retrieve_and_record endpoint, retriever
    end
  end

  def self.retrieve_and_record(endpoint, retriever)
    eval = Evaluation.new
    eval.endpoint_id = endpoint.id

    eval.latest = true
    eval.alive = retriever.alive?

    if eval.alive
      self.retrieve_service_description(retriever, eval)
      self.retrieve_void(retriever, eval)
      self.retrieve_linked_data_rules(retriever, eval)
    end

    eval.alive_rate = Evaluation.calc_alive_rate(eval.alive)
    eval.score = Evaluation.calc_score(eval)
    eval.rank  = Evaluation.calc_rank(eval.score)

    eval.cool_uri_rate = retriever.cool_uri_rate

    eval.save!
  end

  def self.retrieve_service_description(retriever, eval)
    service_description = retriever.service_description
    eval.response_header     = service_description.response_header
    eval.service_description = service_description.text
  end

  def self.retrieve_void(retriever, eval)
    eval.void_uri            = retriever.well_known_uri
    eval.void_ttl            = retriever.void_on_well_known_uri
  end

  def self.retrieve_linked_data_rules(retriever, eval)
    eval.subject_is_uri      = retriever.uri_subject?
    eval.subject_is_http_uri = retriever.http_subject?
    eval.uri_provides_info   = retriever.uri_provides_info?
    eval.contains_links      = retriever.contains_links?
  end

  def self.calc_alive_rate(eval)
    evaluations = self.where(endpoint_id: eval.endpoint_id).where(created_at: (30.days.ago)..(Time.now))	
    count = 0
    evaluations.each do |evaluation|
      count += evaluation.alive? ? 1 : 0  
    end
    return (count / evaluations.size) * 100
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

    score += 25 if !eval.void_ttl.nil?
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
