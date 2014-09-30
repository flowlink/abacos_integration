source 'https://www.rubygems.org'

gem 'sinatra'
gem 'tilt', '~> 1.4.1'
gem 'tilt-jbuilder', require: 'sinatra/jbuilder'

gem 'endpoint_base', github: 'spree/endpoint_base'
gem 'capistrano'
gem 'honeybadger'

gem 'savon'

group :development, :test do
  gem "pry"
end

group :test do
  gem 'vcr'
  gem 'rspec'
  gem 'webmock'
  gem 'rack-test'
end

group :production do
  gem 'foreman'
  gem 'unicorn'
end
