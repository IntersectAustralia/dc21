class PackagesController < DataFilesController


  # GET /packages/1
  # GET /packages/1.json
  def show
    @package = Package.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @package }
    end
  end

  # GET /packages/new
  # GET /packages/new.json
  def new
    @package = Package.new
    set_tab :dashboard, :contentnavigation
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @package }
    end
  end

  # GET /packages/1/edit
  def edit
    @package = Package.find(params[:id])
  end

  # POST /packages
  # POST /packages.json
  def create
    @package = Package.new(params[:package])

    respond_to do |format|
      if @package.save
        format.html { redirect_to @package, notice: 'Package was successfully created.' }
        format.json { render json: @package, status: :created, location: @package }
      else
        format.html { render action: "new" }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

  def create
    files = []
    current_user.data_files.each { |file_group| files << file_group } if current_user.data_files.is_a?(Array)

    @package.filename = params[:filename]
    @package.experiment_id = params[:experiment_id] unless params[:experiment_id].blank?
    @package.file_processing_description = params[:description] unless params[:description].blank?
    @package.file_processing_status= 'PACKAGE'
    @package.created_by = current_user
    @package.path = "/"
    tags = params[:tags]

    #TODO call bagit upload
    #@uploaded_files = []
    #attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], current_user, FileTypeDeterminer.new, MetadataExtractor.new)
    #files.each do |file|
    #  @uploaded_files << attachment_builder.build(file, experiment_id, type, description, tags)
    #end

    respond_to do |format|
      if @package.save
        format.html { redirect_to data_files_path, notice: 'Package was successfully created.' }
        format.json { render json: data_files_path, status: :created, location: @package }
      else
        format.html { render controller: "packages", action: "new" }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end


  # PUT /packages/1
  # PUT /packages/1.json
  def update
    @package = Package.find(params[:id])

    respond_to do |format|
      if @package.update_attributes(params[:package])
        format.html { redirect_to @package, notice: 'Package was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

  def validate_inputs(filename, experiment_id, type, description, tags)
    # we're creating an object to stick the errors on which is kind of weird, but works since we're creating more than one file so don't have a single object already
    @package = Package.new
    @package.errors.add(:base, "Please select an experiment") if experiment_id.blank?
    @package.experiment_id = experiment_id
    @package.file_processing_status = type
    @package.file_processing_description = description
    @package.tag_ids = tags
    !@package.errors.any?
  end

end
