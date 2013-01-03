class PackagesController < DataFilesController

  def new
    @package = Package.new
    set_tab :dashboard, :contentnavigation
  end

  def edit
    @package = Package.find(params[:id])
  end

  def create
    ids = []
    current_user.data_files.each { |file| ids << file.id } if current_user.data_files.is_a?(Array)
    name = params[:filename].strip
    filename = "#{name}.zip" unless name.match(/\.zip$/) or name.empty?
    experiment_id = params[:experiment_id]
    description = params[:description]
    type= 'PACKAGE'
    tags = params[:tags]
    unless validate_inputs(ids, filename, experiment_id, type, description, tags)
      render 'packages/new'
      return
    end
    CustomDownloadBuilder.bagit_for_files_with_ids(ids)  do |zip_file|
      attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], current_user, FileTypeDeterminer.new, MetadataExtractor.new)
      @data_file = attachment_builder.build_named_file(filename, zip_file, experiment_id, type, description, tags)
      respond_to do |format|
        if @data_file
          format.html { redirect_to data_file_path(@data_file), notice: 'Package was successfully created.' }
        else
          format.html { redirect_to  new_package_path, notice: 'Package could not be created.'}
        end
      end
    end
  end

  def validate_inputs(ids, filename, experiment_id, type, description, tags)
    # we're creating an object to stick the errors on which is kind of weird, but works since we're creating more than one file so don't have a single object already
    @package = DataFile.new
    @package.errors.add(:base, "Please provide a filename") if filename.nil? or filename.blank?
    @package.errors.add(:base, "Please select an experiment") if experiment_id.nil? or experiment_id.blank?
    @package.errors.add(:base, "Your cart is empty. Please add some files for packaging") if ids.nil? or ids.empty?
    @package.errors.add(:base, "Description must not exceed 255 characters in length") if description.length > 255
    @package.experiment_id = experiment_id
    @package.file_processing_status = type
    @package.file_processing_description = description
    @package.tag_ids = tags
    !@package.errors.any?
  end

end
