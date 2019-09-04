return unless Rails.env.development?

AdminUser.create!(email: 'admin@example.com', password: 'password', password_confirmation: 'password')

ep1 = Endpoint.create!(name: 'Test', endpoint_url: 'http://localhost:3030/default/sparql', created_at: 7.day.ago, updated_at: 7.day.ago)
ep2 = Endpoint.create!(name: 'Allie', endpoint_url: 'http://data.allie.dbcls.jp/sparql', enabled: false, created_at: 7.day.ago, updated_at: 7.day.ago)
ep3 = Endpoint.create!(name: 'Life Science Dictionary', endpoint_url: 'http://lsd.dbcls.jp/sparql', enabled: false, created_at: 7.day.ago, updated_at: 7.day.ago)

c1 = Crawl.create!(started_at: 1.day.ago, finished_at: 1.day.ago)
c2 = Crawl.create!(started_at: 2.days.ago, finished_at: 2.days.ago)
c3 = Crawl.create!(started_at: 3.days.ago, finished_at: 3.days.ago)
c4 = Crawl.create!(started_at: 4.days.ago, finished_at: 4.days.ago)
c5 = Crawl.create!(started_at: 5.days.ago, finished_at: 5.days.ago)
c6 = Crawl.create!(started_at: 6.days.ago, finished_at: 6.days.ago)
c7 = Crawl.create!(started_at: 7.days.ago, finished_at: 7.days.ago)

Evaluation.create!(alive: false, created_at: 1.day.ago, updated_at: 1.day.ago) do |x|
  x.crawl = c1
  x.endpoint = ep1
end

Evaluation.create!(alive: false, created_at: 2.day.ago, updated_at: 2.day.ago) do |x|
  x.crawl = c2
  x.endpoint = ep1
end

Evaluation.create!(alive: false, created_at: 3.day.ago, updated_at: 3.day.ago) do |x|
  x.crawl = c3
  x.endpoint = ep1
end

Evaluation.create!(alive: false, created_at: 4.day.ago, updated_at: 4.day.ago) do |x|
  x.crawl = c4
  x.endpoint = ep1
end

Evaluation.create!(alive: false, created_at: 5.day.ago, updated_at: 5.day.ago) do |x|
  x.crawl = c5
  x.endpoint = ep1
end

Evaluation.create!(alive: false, created_at: 6.day.ago, updated_at: 6.day.ago) do |x|
  x.crawl = c6
  x.endpoint = ep1
end

Evaluation.create!(alive: false, created_at: 7.day.ago, updated_at: 7.day.ago) do |x|
  x.crawl = c5
  x.endpoint = ep1
end

Evaluation.create!(alive: false, created_at: 1.day.ago, updated_at: 1.day.ago) do |x|
  x.crawl = c1
  x.endpoint = ep2
end

Evaluation.create!(alive: true, created_at: 2.day.ago, updated_at: 2.day.ago) do |x|
  x.crawl = c2
  x.endpoint = ep2
end

Evaluation.create!(alive: false, created_at: 3.day.ago, updated_at: 3.day.ago) do |x|
  x.crawl = c3
  x.endpoint = ep2
end

Evaluation.create!(alive: true, created_at: 4.day.ago, updated_at: 4.day.ago) do |x|
  x.crawl = c4
  x.endpoint = ep2
end

Evaluation.create!(alive: false, created_at: 5.day.ago, updated_at: 5.day.ago) do |x|
  x.crawl = c5
  x.endpoint = ep2
end

Evaluation.create!(alive: true, created_at: 6.day.ago, updated_at: 6.day.ago) do |x|
  x.crawl = c6
  x.endpoint = ep2
end

Evaluation.create!(alive: false, created_at: 7.day.ago, updated_at: 7.day.ago) do |x|
  x.crawl = c7
  x.endpoint = ep2
end

Evaluation.create!(alive: true, created_at: 1.day.ago, updated_at: 1.day.ago) do |x|
  x.crawl = c1
  x.endpoint = ep3
end

Evaluation.create!(alive: true, created_at: 2.day.ago, updated_at: 2.day.ago) do |x|
  x.crawl = c2
  x.endpoint = ep3
end

Evaluation.create!(alive: true, created_at: 3.day.ago, updated_at: 3.day.ago) do |x|
  x.crawl = c3
  x.endpoint = ep3
end

Evaluation.create!(alive: true, created_at: 4.day.ago, updated_at: 4.day.ago) do |x|
  x.crawl = c4
  x.endpoint = ep3
end

Evaluation.create!(alive: true, created_at: 5.day.ago, updated_at: 5.day.ago) do |x|
  x.crawl = c5
  x.endpoint = ep3
end

Evaluation.create!(alive: true, created_at: 6.day.ago, updated_at: 6.day.ago) do |x|
  x.crawl = c6
  x.endpoint = ep3
end

Evaluation.create!(alive: true, created_at: 7.day.ago, updated_at: 7.day.ago) do |x|
  x.crawl = c7
  x.endpoint = ep3
end
