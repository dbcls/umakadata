namespace :crawler do
  desc "check endpoint liveness"
  task :endpoints => :environment do
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      checker = Yummydata::Endpoint.new endpoint.url
      log = CheckLog.new
      log.endpoint_id = endpoint.id
      log.alive = checker.alive?
      log.service_description = checker.service_description.text
      log.response_header = checker.service_description.response_header      
      log.save!
    end
  end

  desc "check endpoint update"
  task :updates => :environment do
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

  desc "check endpoint validity"
  task :validity => :environment do
    Endpoint.all.each do |endpoint|
      puts endpoint.id.to_s + ":" + endpoint.name
      logs = CheckLog.where(:endpoint_id => endpoint.id).order("created_at DESC")
      if logs == nil || !logs[0][:alive]
        next
      end

      begin
        checker = Yummydata::LinkedData.new endpoint.url
        results = checker.check
        rules = LinkedDataRule.new results
        rules.endpoint_id = endpoint.id
        rules.save!
      rescue
        puts "failed."
      end
    end
  end

end
