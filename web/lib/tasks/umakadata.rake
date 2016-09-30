MYAPP = "change path depending on your environment"

SBMETA = "change path depending on your environment"
DOCKER_OPTIONS = "-it"
VOLUME = "-v #{SBMETA}:/sbMeta"
IMAGE = "sbmeta"
SCRIPT_DIR = "/sbMeta/script"
DATA_DIR = "/sbMeta/data"

namespace :umakadata do

  desc "import prefix for all endpoints from CSV file"
  task :import_prefix_for_all_endpoints, ['directory_path'] => :environment do |task, args|
    names = Endpoint.pluck(:name)
    directory_path = args[:directory_path].blank? ? "#{SBMETA}/data/bulkdownloads" : args[:directory_path]
    names.each {|name| Rake::Task["umakadata:import_prefix"].execute(Rake::TaskArguments.new([:name, :directory_path], [name, directory_path]))}
  end

  desc "import prefix from CSV file"
  task :import_prefix, ['name', 'directory_path'] => :environment do |task, args|
    name = args[:name]
    endpoint = Endpoint.where(:name => name).take
    file_path = args[:directory_path].blank? ? "#{SBMETA}/data/bulkdownloads/#{args[:name]}_prefix.csv" : "#{args[:directory_path]}/#{args[:name]}_prefix.csv"
    if !endpoint.nil? && File.exist?(file_path)
      puts file_path
      endpoint.prefixes.destroy_all
      CSV.foreach(file_path, {:headers => true}) do |row|
        Prefix.create(:endpoint_id => endpoint.id, :uri => row[0])
      end
    else
      puts endpoint.name
    end
  end

  desc "Create relations between endpoints for all endpoints"
  task :create_relations_csv_for_all_endpoints, ['directory_path'] => :environment do |task, args|
    all_prefixes_file = "#{SBMETA}/data/all_prefixes.csv"
    directory_path = args[:directory_path].blank? ? "#{SBMETA}/data/bulkdownloads" : args[:directory_path]
    Rake::Task["umakadata:export_prefixes"].execute(Rake::TaskArguments.new([:output_path], [all_prefixes_file]))
    Endpoint.pluck(:name).each do |name|
      Rake::Task["umakadata:create_relations_csv"].execute(Rake::TaskArguments.new([:name, :directory_path], [name, directory_path]))
    end
  end

  desc "Create relations between endpoints for an endpoint"
  task :create_relations_csv, ['name', 'directory_path'] => :environment do |task, args|
    endpoint = Endpoint.where(:name => args[:name]).take
    directory_path = args[:directory_path].blank? ? "#{SBMETA}/data/bulkdownloads" : args[:directory_path]
    if !endpoint.nil? && File.exist?(directory_path + "/" + args[:name])
      Rake::Task["sbmeta:extract"].execute(Rake::TaskArguments.new([:name], [args[:name]]))
      Rake::Task["sbmeta:find_seeAlso_and_sameAs"].execute(Rake::TaskArguments.new([:name, :prefix_path], [args[:name], "#{DATA_DIR}/all_prefixes.csv"]))
      Rake::Task["sbmeta:remove_extractions"].execute(Rake::TaskArguments.new([:name], [args[:name]]))
      Rake::Task["umakadata:seeAlso_sameAs"].execute(Rake::TaskArguments.new([:name, :directory_path], [args[:name], directory_path]))
    else
      puts "#{args[:name]} dose not have bulkdownload files"
    end
  end

  desc "import seeAlso and sameAs data from CSV file"
  task :seeAlso_sameAs, ['name', 'directory_path'] => :environment do |task, args|
    endpoint = Endpoint.where(:name => args[:name]).take
    file_path = args[:directory_path].blank? ? "#{SBMETA}/data/bulkdownloads/#{args[:name]}_relation.csv" : "#{args[:directory_path]}/#{args[:name]}_relation.csv"
    if !endpoint.nil? && File.exist?(file_path)
      endpoint.prefix_filters.destroy_all
      CSV.foreach(file_path, {:headers => true}) do |row|
        Relation.create(:endpoint_id => endpoint.id, :src_id => row[0], :dst_id => row[1], :name => row[2])
      end
    end
  end

  desc "export all prefixes to csv file"
  task :export_prefixes, ['output_path'] => :environment do |task, args|
    path = args[:output_path]
    CSV.open(path, 'w') do |row|
      row << %w(id endpoint_id uri)
      Prefix.all.each {|prefix| row << %W(#{prefix.id} #{prefix.endpoint_id} #{prefix.uri})}
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
    name = args[:name]
    endpoint = Endpoint.where(:name => name).take
    file_path = args[:file_path].blank? ? "#{SBMETA}/data/bulkdownloads/#{name}_subject_and_object_prefix.csv" : args[:file_path]
    if !endpoint.nil? && File.exist?(file_path)
      endpoint.prefix_filters.destroy_all
      CSV.foreach(file_path, {:headers => true}) do |row|
        PrefixFilter.create(:endpoint_id => endpoint.id, :uri => row[0], :element_type => row[2])
      end
    end
  end

  desc "check endpoint liveness (argument: ASC, DESC)"
  task :crawl, ['order'] => :environment do |task, args|
    rdf_prefixes = RdfPrefix.all.pluck(:id, :endpoint_id, :uri)
    Endpoint.all.order("id #{args[:order]}").each do |endpoint|
      rdf_prefixes_candidates = Array.new
      rdf_prefixes.each do |rdf_prefix|
        prefix = rdf_prefix[1] != endpoint.id ? rdf_prefix[2] : nil
        rdf_prefixes_candidates.push prefix unless prefix.nil?
      end
      puts endpoint.name
      begin
        retriever = Umakadata::Retriever.new endpoint.url
        Evaluation.record(endpoint, retriever, rdf_prefixes_candidates)
      rescue => e
        puts e.message
        puts e.backtrace
      end
    end
  end

  desc "test for checking endpoint liveness"
  task :test_crawl, ['name'] => :environment do |task, args|
    rdf_prefixes = RdfPrefix.all.pluck(:id, :endpoint_id, :uri)
    endpoint = Endpoint.where("name LIKE ?", "%#{args[:name]}%").first
    puts endpoint.name
    rdf_prefixes_candidates = Array.new
    rdf_prefixes.each do |rdf_prefix|
      prefix = rdf_prefix[1] != endpoint.id ? rdf_prefix[2] : nil
      rdf_prefixes_candidates.push prefix unless prefix.nil?
    end
    retriever = Umakadata::Retriever.new endpoint.url
    Evaluation.record(endpoint, retriever, rdf_prefixes_candidates)
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

  desc "Fill retrieved_at column in evaluations table"
  task :fill_retrieved_at => :environment do
    Evaluation.all.each do |evaluation|
      if evaluation.retrieved_at.nil?
        evaluation.update_column(:retrieved_at, evaluation.created_at.beginning_of_day)
      end
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
