class PackagesController < DataFilesController



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

  def create
    files = []
    current_user.data_files.each { |file_group| files << file_group } if current_user.data_files.is_a?(Array)
    name = params[:filename].strip
    name = "#{name}.zip" unless name.match(/\.zip$/) or name.empty?
    @package.filename = name
    @package.experiment_id = params[:experiment_id] unless params[:experiment_id].blank?
    @package.file_processing_description = params[:description] unless params[:description].blank?
    @package.file_processing_status= 'PACKAGE'
    @package.created_by = current_user
    @package.path = "/#{name}"
    @package.tag_ids = params[:tags]

    #TODO call bagit upload
    #@uploaded_files = []
    #attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], current_user, FileTypeDeterminer.new, MetadataExtractor.new)
    #files.each do |file|
    #  @uploaded_files << attachment_builder.build(file, experiment_id, type, description, tags)
    #end

    respond_to do |format|
      if @package.save
        @data_file = @package
        format.html { redirect_to data_file_path(@data_file), notice: 'Package was successfully created.' }
        format.json { render json: data_files_path, status: :created, location: @package }
      else
        format.html { render controller: "packages", action: "new" }
        format.json { render json: @package.errors, status: :unprocessable_entity }
      end
    end
  end

end
