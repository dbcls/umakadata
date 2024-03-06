source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'rails', '~> 5.2.3'

# gem 'umakadata', git: 'https://github.com/dbcls/umakadata_gem.git'
gem 'umakadata', path: '../umakadata_gem'

## middleware
gem 'foreman', '~> 0.85.0'
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 5.6'
# pin the rack version to 2.0.7 to avoid conflict with sidekiq
gem 'rack', '2.1.4.2'
gem 'redis', '~> 4.1', '>= 4.1.3'
gem 'redis-rails', '~> 5.0', '>= 5.0.2'
gem 'sendgrid-ruby', '~> 6.0'
gem 'sidekiq', '~> 6.5'
gem 'sidekiq-scheduler', '~> 3.0'
gem 'unicorn', '~> 5.5'

## html
gem 'slim-rails', '~> 3.2'

## js
gem 'js-routes', '~> 1.4', '>= 1.4.9'
gem 'uglifier', '>= 1.3.0'
gem 'webpacker', '~> 5.4', '>= 5.4.3'

## optimization
gem 'bootsnap', '>= 1.1.0', require: false

## utility
gem 'activeadmin', '~> 1.4'
gem 'active_admin_import', '~> 4.2'
gem 'devise', '~> 4.5'
gem 'dotenv-rails', '~> 2.7', '>= 2.7.5'
gem 'jbuilder', '~> 2.5'
gem 'octokit', '~> 4.14'
gem 'omniauth-github', '~> 1.3'
gem 'recaptcha', '~> 5.0'
gem 'simple_form', '~> 5.0'

# asset
gem 'font-awesome-sass', '~> 6.1'

# console
gem 'pry-rails', '~> 0.3.9'

# analysis
gem 'google-analytics-rails', '~> 1.1', '>= 1.1.1'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 3.8'
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'
end
