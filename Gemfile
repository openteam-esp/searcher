source :rubygems

group :default do
  gem 'esp-commons'
  gem 'nokogiri'
  gem 'rails'
  gem 'sunspot_rails'
end

group :development do
  gem 'brakeman'
  gem 'capistrano-db-tasks', :git => 'git://github.com/sgruhier/capistrano-db-tasks'
  gem 'capistrano-unicorn'
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
  gem 'webmock',                       '<1.9'
end
