class HitsController < ApplicationController
  respond_to :json

  def index
    respond_with Hit.search(params[:q], params[:route])
  end
end
