class PagesController < ApplicationController
  respond_to :json

  def index
    respond_with Page.highlighted_hits(params)
  end
end
