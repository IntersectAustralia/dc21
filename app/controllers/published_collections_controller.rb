class PublishedCollectionsController < ApplicationController

  Mime::Type.register "application/zip", :zip

  skip_before_filter :authenticate_user!, :only => [:show]

  load_resource
  authorize_resource :except => [:show]

  def create
    valid = false
    @published_collection = PublishedCollection.new
    package_id = params[:package_id]
    package = Package.find(package_id) unless package_id.nil?
    unless package.nil?
      files = []
      files << package
      if package.published.eql?(true)
        redirect_to  @data_file||data_files_path, :notice => "This package is already submitted for publishing."
      else
        @published_collection.created_by = current_user
        @published_collection.name = package.filename
        @published_collection.description = package.file_processing_description
        if @published_collection.save!
          build_rif_cs(files)
          build_zip_file(package)
          package.set_to_published
          valid = true
        end
      end
    end
    respond_to do |format|
      if valid
        format.html { redirect_to @data_file||data_files_path, :notice =>'Package has been successfully submitted for publishing.' }
        format.json {}
      else
        format.html { redirect_to @data_file||data_files_path, :notice => "Unable to publish package: #{package_id}"}
        format.json {}
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

  def build_zip_file(file)
    dir = APP_CONFIG['published_zip_files_directory']
    Dir.mkdir(dir) unless Dir.exists?(dir)
    output_location = File.join(dir, "data_#{@published_collection.id}.zip")

    # because we now publish packages, we don't need to make a new zip - just copy and rename.
    FileUtils.cp(file.path, output_location)
    @published_collection.zip_file_path = output_location
  end
end
