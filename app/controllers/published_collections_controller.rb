class PublishedCollectionsController < ApplicationController

  load_and_authorize_resource

  def new_from_search
    @published_collection = PublishedCollection.new
  end

  def create
    @published_collection.created_by = current_user
    if @published_collection.save
      redirect_to root_path, notice: 'Your collection has been successfully submitted for publishing.'
    else
      render 'new_from_search'
    end
  end
end
