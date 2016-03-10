class UpdateStatus < ActiveRecord::Base

  belongs_to :endpoint

  def self.record(endpoint, retriever)
    self.transaction do
      self.retrieve_and_record endpoint, retriever
    end
  end

  def self.retrieve_and_record(endpoint, retriever)
    last_updated = retriever.last_modified
    count_first_last = retriever.count_first_last

    current_count = count_first_last[:count].to_i
    current_first = self.concat_statement(count_first_last[:first])
    current_last = self.concat_statement(count_first_last[:last])

    new_update_status = UpdateStatus.new(:endpoint_id => endpoint.id, :count => current_count, :first => current_first, :last => current_last)

    update_status = UpdateStatus.where(:endpoint_id => endpoint.id).order('created_at DESC').first
    if update_status.nil?
      last_updated = Time.now.strftime('%Y-%m-%d %H:%M:%s')
    else
      if last_updated.blank?
        if current_count != update_status.count || current_first != update_status.first || current_last != update_status.last
          last_updated = Time.now.strftime('%Y-%m-%d %H:%M:%s')
        else
          last_updated = endpoint.last_updated
        end
      end
    end
    new_update_status.save!
    endpoint.update(last_updated: last_updated)
  end

  def self.concat_statement(statement)
    return nil if statement.nil?
    result = ''
    statement.each do |key, value|
       result << value
    end
    return result
  end

end
