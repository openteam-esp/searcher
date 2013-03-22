source :rubygems

group :default do
  gem 'esp-commons'
  gem 'nokogiri'
  gem 'progress_bar',                  :require => false
  gem 'rails',                         '~> 3.2.13'
  gem 'sanitize'
  gem 'sunspot_rails',                 '>= 2.0.0.pre.120417'
end

group :development do
  gem 'brakeman'
  gem 'capistrano-ext'
  gem 'rvm-capistrano'
  gem 'sunspot_solr',                  '>= 2.0.0.pre.120417'
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
