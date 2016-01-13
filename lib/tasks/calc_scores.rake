namespace :yummydata do
  desc "Calculate Yummydata score."
  task :calc_scores => :environment do
    Endpoint.all.each do |endpoint|
      puts endpoint.name
      score = Score.new
      score.endpoint_id = endpoint.id
      score.score = Score.calc(endpoint.id)
      score.rank = Score.rank(score.score)
      score.save
    end
  end
end
