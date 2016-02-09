namespace :crawler do
  desc "check endpoint liveness"
  task :endpoints => :environment do
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      retriever = Yummydata::Retriever.new endpoint.url
      log = CheckLog.new
      log.endpoint_id = endpoint.id
      log.alive = retriever.alive?
      log.service_description = retriever.service_description.text
      log.response_header = retriever.service_description.response_header
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
      if logs == nil || logs[0] == nil || !logs[0][:alive]
        next
      end

      begin
        retriever = Yummydata::Retriever.new endpoint.url
        results = {
          subject_is_uri:      retriever.uri_subject?,
          subject_is_http_uri: retriever.http_subject?,
          uri_provides_info:   retriever.uri_provides_info?,
          contains_links:      retriever.contains_links?
        }
        rules = LinkedDataRule.new results
        rules.endpoint_id = endpoint.id
        rules.save!
      rescue
        puts "failed."
      end
    end
  end

  desc "fetch void turtle by well known URI"
  task :well_known_void => :environment do
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      void = Void.new
      retriever = Yummydata::Retriever.new endpoint.url
      begin
        void.endpoint_id = endpoint.id
        void.uri = retriever.well_known_uri
        void.void_ttl = retriever.void_on_well_known_uri
        void.save!
      rescue
        p $!, "failed."
      end
    end
  end

end
