source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

gem 'rails', '~> 5.2.3'

## middleware
gem 'pg', '>= 0.18', '< 2.0'
gem 'puma', '~> 3.11'
# gem 'redis', '~> 4.0'

## css
gem 'sass-rails', '~> 5.0'

## js
gem 'uglifier', '>= 1.3.0'
gem 'webpacker'

## optimization
gem 'bootsnap', '>= 1.1.0', require: false
gem 'turbolinks', '~> 5'

## utility
gem 'jbuilder', '~> 2.5'

group :development, :test do
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'web-console', '>= 3.3.0'

  # gem 'capistrano-rails'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
# gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
