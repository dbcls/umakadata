require 'yaml'

class Tasks::Crawler

  def self.check_endpoints
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      checker = Yummydata::Endpoint.new endpoint.url
      log = CheckLog.new
      log.endpoint_id = endpoint.id
      log.alive = checker.alive?
      log.service_description = checker.service_description?
      log.save!
    end
  end

  def self.check_updates
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      logs = CheckLog.where(:endpoint_id => endpoint.id).order("created_at DESC")
      if logs == nil || !logs[0][:alive]
        next
      end

      last_info = EndpointUpdateInfo.where(:endpoint_id => endpoint.id)
      if last_info.count > 0
        last_info = last_info[0].attributes
        last_info[:samples] = JSON.parse(last_info['samples'])
      else
        last_info = {num_of_triples: 0, samples: []}
      end

      checker = Yummydata::LastUpdate.new endpoint.url
      if checker.updated? last_info
        endpoint.last_updated = Time.zone.now
        checker_info = checker.info
        info = EndpointUpdateInfo.new
        info.endpoint_id = endpoint.id
        info.num_of_triples = checker_info[:num_of_triples]
        info.samples = checker_info[:samples].to_json
        info.save!
      end
    end
  end

  def self.check_validity
    checker = Yummydata::LinkedData.new 'http://data.allie.dbcls.jp/sparql'
    puts checker.check
  end

end
