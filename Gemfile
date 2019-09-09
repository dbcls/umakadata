source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'rails', '~> 5.2.3'

gem 'umakadata', path: '../umakadata_gem'

# quick fix
gem 'sparql-client', git: 'https://github.com/dsatoh/sparql-client.git', branch: 'fix_name_error'

## middleware
gem 'foreman', '~> 0.85.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
gem 'redis', '~> 4.1', '>= 4.1.3'
gem 'sidekiq', '~> 6.0'
gem 'sidekiq-scheduler', '~> 3.0'
gem 'unicorn', '~> 5.5'

## html
gem 'slim-rails', '~> 3.2'

## js
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'

## optimization
gem 'bootsnap', '>= 1.1.0', require: false
gem 'turbolinks', '~> 5'

## utility
gem 'activeadmin', '~> 1.4'
gem 'devise', '~> 4.5'
gem 'dotenv-rails', '~> 2.7', '>= 2.7.5'
gem 'jbuilder', '~> 2.5'

# asset
gem 'font-awesome-sass', '~> 5.4.1'

# console
gem 'pry-rails', '~> 0.3.9'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'

  # gem 'capistrano-rails'
end
