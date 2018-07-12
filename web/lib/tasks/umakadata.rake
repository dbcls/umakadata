STDOUT.sync = true
STDERR.sync = true

MYAPP = "change path depending on your environment"

SBMETA         = "change path depending on your environment"
DOCKER_OPTIONS = "-it"
VOLUME         = "-v #{SBMETA}:/sbMeta"
IMAGE          = "sbmeta"
SCRIPT_DIR     = "/sbMeta/script"
DATA_DIR       = "/sbMeta/data"

namespace :umakadata do

  desc "Add the median function to the database"
  task :active_median => :environment do
    ActiveMedian.create_function
  end

  desc "import endpoints from CSV file"
  task :import_endpoints_from_csv, ['file_path'] => :environment do |task, args|
    file_path = args[:file_path].blank? ? "./db/seeds_data/endpoints.csv" : args[:file_path]
    if File.exists?(file_path)
      puts file_path
      CSV.foreach(file_path, { :headers => true }) do |row|
        Rake::Task["umakadata:import_endpoint"].execute(Rake::TaskArguments.new([:name, :url], [row[0], row[1]]))
      end
    else
      puts "#{file_path} is not found"
    end
  end

  desc "import endpoint"
  task :import_endpoint, ['name', 'url'] => :environment do |task, args|
    name = args[:name].blank? ? nil : args[:name]
    url  = args[:url].blank? ? nil : args[:url]
    unless name.nil? || url.nil?
      puts name
      Endpoint.create(:name => name, :url => url)
    else
      puts "Invalid argument: (name or url)"
    end
  end

  desc "import prefix for all endpoints from CSV file"
  task :import_prefix_for_all_endpoints, ['directory_path'] => :environment do |task, args|
    names          = Endpoint.pluck(:name)
    directory_path = args[:directory_path].blank? ? "#{SBMETA}/data/bulkdownloads" : args[:directory_path]
    names.each { |name| Rake::Task["umakadata:import_prefix"].execute(Rake::TaskArguments.new([:name, :directory_path], [name, directory_path])) }
  end

  desc "import prefix from CSV file"
  task :import_prefix, ['name', 'directory_path'] => :environment do |task, args|
    name      = args[:name]
    endpoint  = Endpoint.where(:name => name).take
    file_path = args[:directory_path].blank? ? "#{SBMETA}/data/bulkdownloads/#{args[:name]}_prefix.csv" : "#{args[:directory_path]}/#{args[:name]}_prefix.csv"
    if !endpoint.nil? && File.exist?(file_path)
      puts file_path
      endpoint.prefixes.destroy_all
      CSV.foreach(file_path, { :headers => true }) do |row|
        Prefix.create(:endpoint_id => endpoint.id, :uri => row[0])
      end
    else
      puts endpoint.name
    end
  end

  desc "Create relations between endpoints for all endpoints"
  task :create_relations_csv_for_all_endpoints, ['directory_path'] => :environment do |task, args|
    all_prefixes_file = "#{SBMETA}/data/all_prefixes.csv"
    directory_path    = args[:directory_path].blank? ? "#{SBMETA}/data/bulkdownloads" : args[:directory_path]
    Rake::Task["umakadata:export_prefixes"].execute(Rake::TaskArguments.new([:output_path], [all_prefixes_file]))
    Endpoint.pluck(:name).each do |name|
      Rake::Task["umakadata:create_relations_csv"].execute(Rake::TaskArguments.new([:name, :directory_path], [name, directory_path]))
    end
  end

  desc "Create relations between endpoints for an endpoint"
  task :create_relations_csv, ['name', 'directory_path'] => :environment do |task, args|
    endpoint       = Endpoint.where(:name => args[:name]).take
    directory_path = args[:directory_path].blank? ? "#{SBMETA}/data/bulkdownloads" : args[:directory_path]
    if !endpoint.nil? && File.exist?("#{directory_path}/#{args[:name]}_relation.csv")
      Rake::Task["sbmeta:extract"].execute(Rake::TaskArguments.new([:name], [args[:name]]))
      Rake::Task["sbmeta:find_seeAlso_and_sameAs"].execute(Rake::TaskArguments.new([:name, :prefix_path], [args[:name], "#{DATA_DIR}/all_prefixes.csv"]))
      Rake::Task["sbmeta:remove_extractions"].execute(Rake::TaskArguments.new([:name], [args[:name]]))
      Rake::Task["umakadata:seeAlso_sameAs"].execute(Rake::TaskArguments.new([:name, :directory_path], [args[:name], directory_path]))
    else
      puts "#{args[:name]} dose not have bulkdownload files"
    end
  end

  desc "Import relation CSV for an endpoint"
  task :import_relation_csv_for_an_endpoint, ['name', 'file_path'] => :environment do |task, args|
    endpoint = Endpoint.where(:name => args[:name]).take
    next puts "#{args[:name]}: No such endpoint endpoint in database." if endpoint.nil?
    next puts "#{args[:file_path]}: No such file of directory." unless File.exist?(args[:file_path])

    endpoint.relations.destroy_all
    CSV.foreach(args[:file_path], { :headers => true }) do |row|
      src_endpoint = Endpoint.where(:name => row[0]).take
      dst_endpoint = Endpoint.where(:name => row[1]).take
      next puts "#{row[0]}: No such endpoint in database." if src_endpoint.nil?
      next puts "#{row[1]}: No such endpoint in database." if dst_endpoint.nil?
      Relation.create(:endpoint_id => endpoint.id, :src_id => src_endpoint.id, :dst_id => dst_endpoint.id, :name => "any")
    end
  end

  desc "import seeAlso and sameAs data for all endpoints"
  task :seeAlso_sameAs_for_all_endpoints, ['directory_path'] => :environment do |task, args|
    directory_path = args[:directory_path].blank? ? "#{SBMETA}/data/bulkdownloads" : args[:directory_path]
    Endpoint.pluck(:name).each do |name|
      Rake::Task["umakadata:seeAlso_sameAs"].execute(Rake::TaskArguments.new([:name, :directory_path], [name, directory_path]))
    end
  end

  desc "import seeAlso and sameAs data from CSV file"
  task :seeAlso_sameAs, ['name', 'directory_path'] => :environment do |task, args|
    endpoint  = Endpoint.where(:name => args[:name]).take
    file_path = args[:directory_path].blank? ? "#{SBMETA}/data/bulkdownloads/#{args[:name]}_relation.csv" : "#{args[:directory_path]}/#{args[:name]}_relation.csv"
    if !endpoint.nil? && File.exist?(file_path)
      endpoint.relations.destroy_all
      puts endpoint.name
      CSV.foreach(file_path, { :headers => true }) do |row|
        Relation.create(:endpoint_id => endpoint.id, :src_id => row[0], :dst_id => row[1], :name => row[2])
      end
    end
  end

  desc "export all prefixes to csv file"
  task :export_prefixes, ['output_path'] => :environment do |task, args|
    path = args[:output_path]
    CSV.open(path, 'w') do |row|
      row << %w(id endpoint_id uri)
      Prefix.all.each { |prefix| row << %W(#{prefix.id} #{prefix.endpoint_id} #{prefix.uri}) }
    end
  end

  desc "import prefix filters for all endpoints from CSV file"
  task :import_prefix_filters_for_all_endpoints, ['directory_path'] => :environment do |task, args|
    names = Endpoint.pluck(:name)
    names.each do |name|
      file_path = args[:directory_path].blank? ? nil : "#{args[:directory_path]}/#{name}_subject_and_object_prefix.csv"
      Rake::Task["umakadata:import_prefix_filters"].execute(Rake::TaskArguments.new([:name, :file_path], [name, file_path]))
    end
  end

  desc "import prefix filters from CSV file"
  task :import_prefix_filters, ['name', 'file_path'] => :environment do |task, args|
    name      = args[:name]
    endpoint  = Endpoint.where(:name => name).take
    file_path = args[:file_path].blank? ? "#{SBMETA}/data/bulkdownloads/#{name}_subject_and_object_prefix.csv" : args[:file_path]
    if !endpoint.nil? && File.exist?(file_path)
      endpoint.prefix_filters.destroy_all
      CSV.foreach(file_path, { :headers => true }) do |row|
        PrefixFilter.create(:endpoint_id => endpoint.id, :uri => row[0], :element_type => row[2])
      end
    end
  end

  desc "check endpoint liveness (argument: ASC, DESC)"
  task :crawl, ['order'] => :environment do |task, args|
    time      = Time.zone.now
    crawl_log = CrawlLog.where(started_at: time.all_day).take
    if crawl_log.blank?
      crawl_log = CrawlLog.create(started_at: time)
    end
    rdf_prefixes = RdfPrefix.all.pluck(:id, :endpoint_id, :uri)
    Endpoint.all.order("id #{args[:order]}").each do |endpoint|
      next if endpoint.disable_crawling
      crawl_log.evaluations.where(endpoint_id: endpoint.id).delete_all

      rdf_prefixes_candidates = Array.new
      rdf_prefixes.each do |rdf_prefix|
        prefix = rdf_prefix[1] != endpoint.id ? rdf_prefix[2] : nil
        rdf_prefixes_candidates.push prefix unless prefix.nil?
      end
      puts endpoint.name
      begin
        retriever  = Umakadata::Retriever.new endpoint.url, time
        evaluation = Evaluation.record(endpoint, retriever, rdf_prefixes_candidates)
        evaluation.update_column(:crawl_log_id, crawl_log.id) unless evaluation.nil?
      rescue => e
        puts e.message
        puts e.backtrace
      end
    end
    crawl_log.update_column(:finished_at, Time.zone.now)
  end

  namespace :crawler do
    desc "crawl an endpoint"
    task :run, %w[endpoint_id crawl_log_id start_time] => :environment do |task, args|
      endpoint_id  = args[:endpoint_id] || raise(ArgumentError, 'endpoint_id is nil')
      crawl_log_id = args[:crawl_log_id] || raise(ArgumentError, 'crawl_log_id is nil')
      start_time = args[:start_time] || raise(ArgumentError, 'start_time is nil')

      endpoint = Endpoint.find(endpoint_id.to_i)
      next if endpoint.disable_crawling

      puts endpoint.name

      crawl_log = CrawlLog.find(crawl_log_id.to_i)
      crawl_log.evaluations.where(endpoint_id: endpoint.id).delete_all

      rdf_prefixes_candidates = RdfPrefix.where.not(endpoint_id: endpoint.id).pluck(:uri)

      begin
        retriever  = Umakadata::Retriever.new endpoint.url, Time.zone.parse(start_time)
        evaluation = Evaluation.record(endpoint, retriever, rdf_prefixes_candidates)
        evaluation.update_column(:crawl_log_id, crawl_log.id) unless evaluation.nil?
      rescue => e
        puts e.message
        puts e.backtrace
      end
    end

    namespace :endpoint do
      desc "list endpoint IDs"
      task :list, ['order'] => :environment do |task, args|
        puts Endpoint.all.order("id #{args[:order]}").pluck(:id).join("\n")
      end
    end

    namespace :crawl_log do
      desc "create a crawl log and return crawl log ID and current time"
      task create: :environment do
        time      = Time.zone.now
        crawl_log = CrawlLog.create(started_at: time)
        puts crawl_log.id, time
      end

      desc "terminate crawl log"
      task :terminate, ['crawl_log_id'] => :environment do |task, args|
        crawl_log_id = (n = args[:crawl_log_id]).present? ? n.to_i : raise(ArgumentError, 'crawl_log_id is nil')

        crawl_log = CrawlLog.find(crawl_log_id)
        crawl_log.update_column(:finished_at, Time.zone.now)
      end
    end
  end

  desc "test for checking endpoint liveness"
  task :test_crawl, ['name'] => :environment do |task, args|
    rdf_prefixes = RdfPrefix.all.pluck(:id, :endpoint_id, :uri)
    endpoint     = Endpoint.where("name LIKE ?", "%#{args[:name]}%").first
    puts endpoint.name
    rdf_prefixes_candidates = Array.new
    rdf_prefixes.each do |rdf_prefix|
      prefix = rdf_prefix[1] != endpoint.id ? rdf_prefix[2] : nil
      rdf_prefixes_candidates.push prefix unless prefix.nil?
    end
    retriever = Umakadata::Retriever.new endpoint.url, Time.zone.now
    Evaluation.record(endpoint, retriever, rdf_prefixes_candidates)
  end

  desc "test for checking retriever method all endpoints"
  task :retriever_method, ['method_name'] => :environment do |task, args|
    puts "endpoint_name|dead/alive|result|log"
    Endpoint.all.each do |endpoint|
      retriever = Umakadata::Retriever.new endpoint.url, Time.zone.now

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
    endpoint  = Endpoint.where("name LIKE ?", "%#{args[:name]}%").first
    retriever = Umakadata::Retriever.new endpoint.url, Time.zone.now

    # if retriever.alive?
    logger = Umakadata::Logging::Log.new
    puts endpoint.name + "|alive|" + retriever.send(args[:method_name], logger: logger).to_s + "|" + logger.as_json.to_s
    # else
    #   puts endpoint.name + "|dead|x|x|"
    # end
  end

  desc "Fill retrieved_at column in evaluations table"
  task :fill_retrieved_at => :environment do
    Evaluation.where(:retrieved_at => nil).each do |evaluation|
      puts evaluation.id
      evaluation.update_column(:retrieved_at, evaluation.created_at.beginning_of_day)
    end
  end

  desc "Create crawl log records and fill crawl_log_id to evaluations"
  task :create_crawl_log_and_fill_crawl_log_id => :environment do
    group_by_day = Evaluation.select("date(created_at)").group("date(created_at)").order("date(created_at)")
    group_by_day.each do |group|
      CrawlLog.create(:started_at => group.date, :finished_at => group.date)
    end

    CrawlLog.all.each do |crawl_log|
      evaluations = Evaluation.where(:created_at => crawl_log.started_at.all_day)
      evaluations.update_all(:crawl_log_id => crawl_log.id)
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
    GithubHelper.list_issues({ :state => 'all' }).each { |issue|
      issue_id = issue[:number]
      next if issue_id >= ignore_id_min
      endpoint = Endpoint.where(name: issue[:title]).take

      if endpoint.nil?
        begin
          GithubHelper.close_issue(issue_id)
        rescue => e
          p e.message
          next
        end
      end
      ActiveRecord::Base.transaction do
        # do not return callback after update
        endpoint.update_column(:issue_id, issue_id)
      end
    }
  end

  desc "Create label for each endpoint"
  task :create_label_for_each_endpoint => :environment do
    Endpoint.all.each_with_index do |endpoint, index|
      begin
        label_name = endpoint.name.gsub(",", "")
        label      = GithubHelper.add_label(label_name, Color.get_color(endpoint.id))
        endpoint.update_column(:label_id, label[:id])
      rescue => e
        p e.message
      end
    end
  end

  desc "Add label to existing issues"
  task :add_label_to_existing_issues => :environment do
    GithubHelper.list_issues({ :state => 'all', :label => "endpoints" }).each do |issue|
      endpoint = Endpoint.where(name: issue[:title]).take

      if endpoint.nil?
        puts issue[:title]
        next
      end
      label = endpoint.name.gsub(",", "")
      begin
        GithubHelper.add_labels_to_an_issue(issue[:number], [label])
      rescue => e
        p e.message
      end
    end
  end

  desc "Export all endpoints information as csv foramt"
  task :export_endpoints => :environment do
    puts "endpoint_id,name,url,download_url"
    Endpoint.all.each_with_index do |endpoint, index|
      puts ('%d,"%s","%s",' % [endpoint.id, endpoint.name, endpoint.url])
    end
  end

end

namespace :sbmeta do

  desc "Create prefix list"
  task :create_prefixes_csv_files, ['name'] => :environment do |task, args|
    Rake::Task["sbmeta:download"].execute(Rake::TaskArguments.new([:name], [args[:name]]))
    Rake::Task["sbmeta:extract"].execute(Rake::TaskArguments.new([:name], [args[:name]]))
    Rake::Task["sbmeta:find_prefixes"].execute(Rake::TaskArguments.new([:name], [args[:name]]))
  end

  desc "Bulkdownload from each endpoint to bulkdownload directory"
  task :download, ['name'] => :environment do |task, args|
    command = "/bin/bash #{SCRIPT_DIR}/download.sh #{args[:name]}"
    sh "docker run #{DOCKER_OPTIONS} #{VOLUME} #{IMAGE} #{command}"
  end

  desc "Extract from each endpoint to bulkdownload directory"
  task :extract, ['name'] => :environment do |task, args|
    command = "/bin/bash #{SCRIPT_DIR}/extract.sh #{args[:name]}"
    sh "docker run #{DOCKER_OPTIONS} #{VOLUME} #{IMAGE} #{command}"
  end

  desc "remove all extract files"
  task :remove_extractions, ['name'] => :environment do |task, args|
    command = "rm -rf #{DATA_DIR}/bulkdownloads/#{args[:name]}/extractions"
    sh "docker run #{DOCKER_OPTIONS} #{VOLUME} #{IMAGE} #{command}"
  end

  desc "Find prefixes in bulkdownload directory and output standardized them in CSV file"
  task :find_prefixes, ['name'] => :environment do |task, args|
    command = "/bin/bash #{SCRIPT_DIR}/create_prefixes.sh #{args[:name]}"
    sh "docker run #{DOCKER_OPTIONS} #{VOLUME} #{IMAGE} #{command}"
  end

  desc "Find seeAlso and sameAs for an endpoint"
  task :find_seeAlso_and_sameAs, ['name', 'prefix_path'] => :environment do |task, args|
    command = "sbt \"runMain sbmeta.SBMetaSeeAlsoAndSameAs #{DATA_DIR}/bulkdownloads/#{args[:name]} #{args[:prefix_path]}\""
    sh "docker run #{DOCKER_OPTIONS} #{VOLUME} #{IMAGE} #{command}"
  end

end
