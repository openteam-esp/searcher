class HitsController < ApplicationController
  respond_to :json

  delegate :hits, :to => :search_results

  def index
    headers['X-Current-Page'] = hits.current_page.to_s
    headers['X-Total-Pages'] = hits.total_pages.to_s
    headers['X-Total-Count'] = hits.total_count.to_s

    respond_with hits.map{|hit| Hit.new(hit)}
  end

  private
    def search_results
      @search_results ||= Page.search_by(params)
    end
end
