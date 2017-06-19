class LinkedDataRule < ActiveRecord::Base

  def self.calc_score(id)
    rule = self.find_by(:endpoint_id => id)
    if rule.nil?
      return '-'
    end
    count = 0
    count += rule[:subject_is_uri] ? 1 : 0
    count += rule[:subject_is_http_uri] ? 1 : 0
    count += rule[:uri_provides_info] ? 1 : 0
    count += rule[:contains_links] ? 1 : 0
    @linked_data_rule_score = (count / 4.0 * 100).to_s
  end

end
