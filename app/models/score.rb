class Score < ActiveRecord::Base

  def self.calc(endpoint_id)
    score = 0
    check_log = CheckLog.where({:endpoint_id => endpoint_id}).order(created_at: :desc).first
    return if check_log.nil?

    score += 15 if check_log.alive

    score += 15 if check_log.service_description

    linked_data_rule_score = LinkedDataRule.calc_score(endpoint_id)
    score += linked_data_rule_score.to_i / 4

    void = Void.where({:endpoint_id => endpoint_id}).order(created_at: :desc).first
    score += 25 if void.nil?
    return score
  end

  def self.rank(score)
    return case
    when  0 <= score && score < 30 then 1
    when 30 <= score && score < 50 then 2
    when 50 <= score && score < 70 then 3
    when 70 <= score && score < 85 then 4
    when 85 <= score                then 5
    end
  end

end
