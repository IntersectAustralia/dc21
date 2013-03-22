require File.expand_path('../../../lib/exceptions/template_error.rb', __FILE__)
class PackagesController < DataFilesController

  def new
    if current_user.data_files.empty?

    else
      @back_request = request.referer
      @package = Package.new
      @package.set_times(current_user)
      set_tab :dashboard, :contentnavigation
    end
  end

  def edit
    @package = Package.find(params[:id])
  end

  def create
    @package = Package.create_package(params, current_user)
    if @package.save
      data_file_ids = CartItem.data_ids_which_belong_to_user(current_user)
      begin
        CustomDownloadBuilder.bagit_for_files_with_ids(data_file_ids, @package) do |zip_file|
          attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], current_user, FileTypeDeterminer.new, MetadataExtractor.new)
          package = attachment_builder.build_package(@package, zip_file)
          build_rif_cs(package) unless package.nil?
        end
        redirect_to data_file_path(@package), notice: 'Package was successfully created.'
      rescue ::TemplateError => e
        logger.error e.message
        redirect_to data_file_path(@package), alert: 'There were errors in the README.html template file.'
      end

    else
      @package.reformat_on_error(params[:package][:filename])
      render :action => 'new'
    end
  end

  def publish
    begin
      valid = false
      unless @package.nil?
        if @package.published.eql?(true)
          redirect_to data_files_path, :notice => "This package is already submitted for publishing."
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
