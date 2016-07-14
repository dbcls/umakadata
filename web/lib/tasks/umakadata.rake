namespace :umakadata do

  desc "check endpoint liveness"
  task :crawl => :environment do
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      begin
        retriever = Umakadata::Retriever.new endpoint.url
        Evaluation.record(endpoint, retriever)
      rescue => e
        puts e.message
        puts e.backtrace
      end
    end
  end

  desc "test for checking endpoint liveness"
  task :test_crawl, ['name'] => :environment do |task, args|
    endpoint = Endpoint.where("name LIKE ?", "%#{args[:name]}%").first
    puts endpoint.name
    retriever = Umakadata::Retriever.new endpoint.url
    Evaluation.record(endpoint, retriever)
  end

  desc "test for checking retriever method all endpoints"
  task :retriever_method, ['method_name'] => :environment do |task, args|
    puts "endpoint_name|dead/alive|result|log"
    Endpoint.all.each do |endpoint|
      retriever = Umakadata::Retriever.new endpoint.url

      if retriever.alive?
        logger = Umakadata::Logging::Log.new
        puts endpoint.name + "|alive|" + retriever.send(args[:method_name], logger: logger).to_s + "|" + logger.as_json.to_s
      else
        puts endpoint.name + "|dead|x|x|"
      end
    end
  end

  desc "test for checking retriever method"
  task :test_retriever_method, ['name', 'method_name'] => :environment do |task, args|
    puts "endpoint_name|dead/alive|result|log"
    endpoint = Endpoint.where("name LIKE ?", "%#{args[:name]}%").first
    retriever = Umakadata::Retriever.new endpoint.url

    if retriever.alive?
      logger = Umakadata::Logging::Log.new
      puts endpoint.name + "|alive|" + retriever.send(args[:method_name], logger: logger).to_s + "|" + logger.as_json.to_s
    else
      puts endpoint.name + "|dead|x|x|"
    end
  end

  desc "create issue_id to all endpoints"
  task :create_issue_ids => :environment do
    Endpoint.all.each do |endpoint|
      endpoint.save
    end
  end

  desc "Fix difference between endpoint_ids and issue_ids in forum"
  task :fix_different_issue_id => :environment do
    ignore_id_min = 103
    GithubHelper.list_issues.each {|issue|
      issue_id = issue[:number]
      next if issue_id >= ignore_id_min
      endpoint = Endpoint.where(name: issue[:title]).take

      if endpoint.nil?
        GithubHelper.close_issue(issue_id)
        next
      end
      ActiveRecord::Base.transaction do
        # do not return callback after update
        endpoint.update_column(:issue_id, issue_id)
      end
    }
  end
end
