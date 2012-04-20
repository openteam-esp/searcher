class HitsController < ApplicationController
  respond_to :json

  def index
    respond_with Page.hits(params[:q], params[:route])
  end
end
