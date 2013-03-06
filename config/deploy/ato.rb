settings_yml_path = 'config/deploy.yml'
config = YAML::load(File.open(settings_yml_path))
raise 'not found deploy key in settings.yml. see settings.yml.example' unless config['deploy']
application = config['deploy']['ato']['application']
raise 'not found deploy.application key in settings.yml. see settings.yml.example' unless application
domain = config['deploy']['ato']['domain']
raise 'not found deploy.domain key in settings.yml. see settings.yml.example' unless domain

set :application, application
set :domain, domain

set :ssh_options, { :forward_agent => true }

set :rails_env, "production"
set :deploy_to, "/srv/#{application}"
set :use_sudo, false
set :unicorn_instance_name, "unicorn"

set :scm, :git
set :repository, "git://github.com/openteam-esp/searcher.git"
set :branch, "master"
set :deploy_via, :remote_cache

set :repository_cache, "cached_copy"

set :keep_releases, 7

set :bundle_gemfile,  "Gemfile"
set :bundle_dir,      File.join(fetch(:shared_path), 'bundle')
set :bundle_flags,    "--deployment --quiet --binstubs"
set :bundle_without,  [:development, :test]

role :web, domain
role :app, domain
role :db,  domain, :primary => true

# remote database.yml
database_yml_path = "config/database.yml"
config = YAML::load(capture("cat #{deploy_to}/shared/#{database_yml_path}"))
adapter = config[rails_env]["adapter"]
database = config[rails_env]["database"]
db_username = config[rails_env]["username"]
host = config[rails_env]["host"]

#local database.yml
config = YAML::load(File.open(database_yml_path))
local_rails_env = 'development'
local_adapter = config[local_rails_env]["adapter"]
local_database = config[local_rails_env]["database"]
local_db_username = config[local_rails_env]["username"]

set :timestamp, Time.now.strftime("%Y-%m-%d-%H-%M")
namespace :db do
  desc "download data to local database"
  task :import do
    run_locally("bin/rake sunspot:solr:stop; true")
    run_locally("bin/rake db:drop")
    run_locally("bin/rake db:create")
    run_locally("ssh #{domain} pg_dump -U #{db_username} #{database} -O | psql #{local_database}")
    run_locally("bin/rake sunspot:solr:start")
    run_locally("bin/rake db:migrate")
    run_locally("bin/rake db:migrate RAILS_ENV=test")
  end
end

namespace :deploy do
  desc "Copy config files"
  task :config_app, :roles => :app do
    run "ln -s #{deploy_to}/shared/config/settings.yml #{release_path}/config/settings.yml"
    run "ln -s #{deploy_to}/shared/config/database.yml #{release_path}/config/database.yml"
  end

  desc "Copy unicorn.rb file"
  task :copy_unicorn_config do
    run "mv #{deploy_to}/current/config/unicorn.rb #{deploy_to}/current/config/unicorn.rb.example"
    run "ln -s #{deploy_to}/shared/config/unicorn.rb #{deploy_to}/current/config/unicorn.rb"
  end

  desc "Reload Unicorn"
  task :reload_servers do
    run "/usr/local/etc/rc.d/#{unicorn_instance_name} restart"
  end

  desc "Airbrake notify"
  task :airbrake do
    run "cd #{deploy_to}/current && RAILS_ENV=production TO=production bin/rake airbrake:deploy"
  end
end

namespace :unicorn do
  desc "Start Unicorn"
  task :start do
    run "/usr/local/etc/rc.d/unicorn start"
  end

  desc "Stop Unicorn"
  task :stop do
    run "/usr/local/etc/rc.d/unicorn stop"
  end

  desc "Reload Unicorn"
  task :reload do
    run "/usr/local/etc/rc.d/unicorn reload"
  end

  desc "Restart Unicorn"
  task :restart do
    run "/usr/local/etc/rc.d/unicorn restart"
  end
end

namespace :subscriber do
  desc "Start rabbitmq subscriber"
  task :start do
    run "/usr/local/etc/rc.d/searcher-subscriber.sh start"
  end

  desc "Stop rabbitmq subscriber"
  task :stop do
    run "/usr/local/etc/rc.d/searcher-subscriber.sh stop"
  end

  desc "Restart rabbitmq subscriber"
  task :restart do
    run "/usr/local/etc/rc.d/searcher-subscriber.sh restart"
  end
end

# stop subscribers
before "deploy", "subscriber:stop"

# deploy
after "deploy:finalize_update", "deploy:config_app"
after "deploy", "deploy:migrate"
after "deploy", "deploy:copy_unicorn_config"
after "deploy", "deploy:reload_servers"
after "deploy", "subscriber:restart"
after "deploy:restart", "deploy:cleanup"
after "deploy", "deploy:airbrake"

# deploy:rollback
after "deploy:rollback", "deploy:reload_servers"
