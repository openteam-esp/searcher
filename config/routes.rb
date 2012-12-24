Searcher::Application.routes.draw do
  root :to => 'hits#index', :defaults => { :format => :json }
end
