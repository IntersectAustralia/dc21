class PublishedCollectionsController < ApplicationController

  Mime::Type.register "application/zip", :zip

  skip_before_filter :authenticate_user!, :only => [:show]

  load_resource
  authorize_resource :except => [:show]

  def new_from_search
    @published_collection = PublishedCollection.new
    #TODO: currently this means you can't do two sets of publishing in different windows...
    session[:search_for_publishing] = DataFileSearch.new(params[:search])
  end

  def create
    redirect_to root_path, notice: 'Your collection has been successfully submitted for publishing.'


#    @published_collection.created_by = current_user
#    if @published_collection.save
#      search = session[:search_for_publishing]
#      files = search.do_search(DataFile.accessible_by(current_ability))
#
#      build_rif_cs(files)
#      build_zip_file(files)
#      @published_collection.save!
#      redirect_to root_path, notice: 'Your collection has been successfully submitted for publishing.'
#    else
#      render 'new_from_search'
#    end
  end

  def show
    respond_to do |format|
      #eventually we may have an HTML version, but for now we only support accessing the zip file for the collection
      format.zip do
        send_file @published_collection.zip_file_path, :type => 'application/zip', :disposition => 'attachment', :filename => "collection_#{@published_collection.id}.zip"
      end
    end
  end

  private

  def build_rif_cs(files)
    dir = APP_CONFIG['published_rif_cs_directory']
    Dir.mkdir(dir) unless Dir.exists?(dir)
    output_location = File.join(dir, "rif-cs-#{@published_collection.id}.xml")

    file = File.new(output_location, 'w')

    options = {:root_url => root_url,
               :collection_url => published_collection_url(@published_collection),
               :zip_url => published_collection_url(@published_collection, :format => 'zip'),
               :submitter => current_user}
    RifCsGenerator.new(PublishedCollectionRifCsWrapper.new(@published_collection, files, options), file).build_rif_cs
    file.close

    @published_collection.rif_cs_file_path = output_location
  end

  def build_zip_file(files)
    dir = APP_CONFIG['published_zip_files_directory']
    Dir.mkdir(dir) unless Dir.exists?(dir)
    output_location = File.join(dir, "data_#{@published_collection.id}.zip")

    CustomDownloadBuilder.zip_for_files_with_ids(files.collect(&:id)) do |zip_file|
      zip_file.close
      FileUtils.cp(zip_file.path, output_location)
    end

    @published_collection.zip_file_path = output_location
  end
end
