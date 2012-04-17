class PublishedCollectionsController < ApplicationController

  load_and_authorize_resource

  def new_from_search
    @published_collection = PublishedCollection.new
  end

  def create
    @published_collection.created_by = current_user
    if @published_collection.save
      build_rif_cs
      redirect_to root_path, notice: 'Your collection has been successfully submitted for publishing.'
    else
      render 'new_from_search'
    end
  end

  private

  #TODO: refactor me elsewhere, make sure the whole create action is transactional
  def build_rif_cs
    dir = File.join(APP_CONFIG['files_root'], 'rif-cs')
    Dir.mkdir(dir) unless Dir.exists?(dir)
    output_location = File.join(dir, "rif-cs-#{@published_collection.id}.xml")

    file = File.new(output_location, 'w')
    RifCsGenerator.new(PublishedCollectionRifCsWrapper.new(@published_collection), file).build_rif_cs
    file.close

    @published_collection.rif_cs_file_path = output_location
    @published_collection.save!
  end

end
