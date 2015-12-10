require 'openteam/capistrano/recipes'

set :default_stage, :ato

set :shared_children, fetch(:shared_children) + %w[config/sunspot.yml]
