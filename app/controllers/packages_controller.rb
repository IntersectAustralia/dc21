class PackagesController < DataFilesController

  def new
    if current_user.data_files.empty?

    else
      @back_request = request.referer
      @package = Package.new
      early_start_time = CartItem.data_file_with_earliest_start_time(current_user.id).first.data_file.start_time
      late_end_time = CartItem.data_file_with_latest_end_time(current_user.id).first.data_file.start_time
      @package.start_time = early_start_time
      @package.end_time = late_end_time
      set_tab :dashboard, :contentnavigation
    end


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
      @package = attachment_builder.build_named_file(filename, zip_file, experiment_id, type, description, tags)
      unless @package.nil?
        files = []
        files << @package
        build_rif_cs(files)

      end
      respond_to do |format|
        if @package
          @data_file = @package
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
    @package.experiment_id = experiment_id
    @package.file_processing_status = type
    @package.file_processing_description = description
    @package.tag_ids = tags
    !@package.errors.any?
  end

  def publish
    begin
      valid = false
      unless @package.nil?
        if @package.published.eql?(true)
          redirect_to  data_files_path, :notice => "This package is already submitted for publishing."
        else
          if @package.save! and publish_rif_cs
              @package.set_to_published(current_user)
              valid = true
          end
        end
      end
    rescue
      valid = false
    end

    redirect_to data_files_path, :notice => valid ? "Package has been successfully submitted for publishing." : "Unable to publish package."
  end

  def reformat_date_and_time(date, hr, min, sec)
    return if date.blank?
    adjusted_date = date #so we can use << without modifying the original
    if hr.present? && min.present? && sec.present?
      adjusted_date << " " << hr << ":" << min << ":" << sec
    end
    return adjusted_date << "UTC"
  end

  def build_rif_cs(files)
    #build the rif-cs and place in the unpublished_rif_cs folder, where it will stay until published in DC21
    dir = APP_CONFIG['unpublished_rif_cs_directory']
    Dir.mkdir(dir) unless Dir.exists?(dir)
    output_location = File.join(dir, "rif-cs-#{@package.id}.xml")

    file = File.new(output_location, 'w')

    options = {:root_url => root_url,
               :collection_url => data_file_path(@package),
               :zip_url => download_data_file_url(@package),
               :submitter => current_user}
    RifCsGenerator.new(PackageRifCsWrapper.new(@package, files, options), file).build_rif_cs
    file.close
  end

  def publish_rif_cs
    #TODO set new 'submitter' value
    dir = APP_CONFIG['published_rif_cs_directory']
    unpublished_dir = APP_CONFIG['unpublished_rif_cs_directory']
    Dir.mkdir(dir) unless Dir.exists?(dir)
    output_location = File.join(dir, "rif-cs-#{@package.id}.xml")
    unpublished_location = File.join(unpublished_dir, "rif-cs-#{@package.id}.xml")
    FileUtils.mv(unpublished_location, output_location)
    true
  end

end
