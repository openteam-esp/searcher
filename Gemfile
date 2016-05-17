source 'https://rubygems.org'

group :default do
  gem 'awesome_print'
  gem 'airbrake', '~> 4.3.4'
  gem 'esp-commons'
  gem 'nokogiri'
  gem 'progress_bar'
  gem 'rails', '~> 3.2.13'
  gem 'sunspot_rails'
end

group :development do
  gem 'brakeman'
  gem 'capistrano', '~> 2.15.5', :require => false
  gem 'capistrano-db-tasks', :git => 'git://github.com/sgruhier/capistrano-db-tasks', :ref => '396cbbf', :require => false
  gem 'capistrano-unicorn', '~> 0.1.10', :require => false
  gem 'openteam-capistrano'
  gem 'sunspot_solr'
end

group :production do
  gem 'pg'
end

group :test do
  gem 'rspec-rails'
  gem 'sqlite3'
  gem 'sunspot_matchers'
  gem 'vcr'
  gem 'webmock', '<1.9'
end
