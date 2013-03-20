require 'csv'

class DataFilesController < ApplicationController

  ALLOWED_SORT_PARAMS = %w(users.email data_files.filename data_files.created_at data_files.file_processing_status data_files.experiment_id data_files.file_size)
  SAVE_MESSAGE = 'The data file was saved successfully.'

  before_filter :authenticate_user!, :except => [:download]
  before_filter :sort_params, :only => [:index, :search]
  before_filter :search_params, :only => [:index, :search]
  before_filter :page_params, :only => [:index]
  load_and_authorize_resource :except => [:download]
  load_resource :only => [:download]
  set_tab :home
  helper_method :sort_column, :sort_direction
  layout 'data_files'

  expose(:tags) { Tag.order(:name) }
  expose(:facilities) { Facility.order(:name) }
  expose(:variables) { ColumnMapping.mapped_column_names_for_search }
  expose(:experiments) { Experiment.order(:name) }
  expose(:column_mappings) { ColumnMapping.all }

  def index
    set_tab :explore, :contentnavigation
    do_search(params[:search])
    @data_files_paginated = @data_files.paginate(page: params[:page])
  end

  def search
    session[:page] = nil
    set_tab :explore, :contentnavigation
    do_search(params[:search])
    @data_files_paginated = @data_files.paginate(page: params[:page])
    render :index
  end

  def clear
    session["search"] = nil
    set_tab :explore, :contentnavigation
    do_search(params[:search])
    @data_files_paginated = @data_files.paginate(page: params[:page])
    render :index
  end

  def show
    set_tab :explore, :contentnavigation
    @column_mappings = ColumnMapping.all
  end

  def new
    @uploaded_files = []
    # set_tab :dashboard, :contentnavigation
  end

  def edit
    @column_mappings = ColumnMapping.all
  end

  def update
    @data_file.tag_ids = params[:tags]

    if !params[:date].nil?
      attrs = params.delete(:date)
      start_time = reformat_date_and_time(attrs[:start_time], attrs[:start_hr], attrs[:start_min], attrs[:start_sec])
      end_time = reformat_date_and_time(attrs[:end_time], attrs[:end_hr], attrs[:end_min], attrs[:end_sec])
      params[:data_file][:start_time] = start_time
      params[:data_file][:end_time] = end_time
    end

    old_filename = @data_file.filename
    if @data_file.update_attributes(params[:data_file])
      @data_file.rename_file(old_filename, params[:data_file][:filename], APP_CONFIG['files_root']) unless @data_file.is_package?
      redirect_to data_file_path, notice: SAVE_MESSAGE
    else
      render action: "edit"
    end

  end

  def create
    begin
      files = []
      params[:files].each { |file_group| files << file_group } if params[:files].is_a?(Array)

      experiment_id = params[:experiment_id]
      description = params[:description]
      type = params[:file_processing_status]
      tags = params[:tags]

      unless validate_inputs(files, experiment_id, type, description, tags)
        render :new
        return
      end

      @uploaded_files = []
      attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], current_user, FileTypeDeterminer.new, MetadataExtractor.new)
      files.each do |file|
        @uploaded_files << attachment_builder.build(file, experiment_id, type, description, tags)
      end
    ensure
      clean_up_temp_files(files)
    end

  end

  def api_create
    begin
      attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], current_user, FileTypeDeterminer.new, MetadataExtractor.new)

      file = params[:file]
      type = params[:type]
      experiment_id = params[:experiment_id]
      tag_names = params[:tag_names]
      errors, tag_ids = validate_api_inputs(file, type, experiment_id, tag_names)

      if errors.empty?
        uploaded_file = attachment_builder.build(file, experiment_id, type, params[:description], tag_ids)
        messages = uploaded_file.messages.collect { |m| m[:message] }
        render :json => {:file_id => uploaded_file.id, :messages => messages, :file_name => uploaded_file.filename, :file_type => uploaded_file.file_processing_status}
      else
        render :json => {:messages => errors}, :status => :bad_request
      end
    ensure
      clean_up_temp_files([file])
    end
  end

  def bulk_update
    successful_complete_update = true
    @uploaded_files = []

    params[:files].each do |id, attrs|

      attrs.merge!(params[:date][:files][id]) if  params[:date].present? && params[:date][:files][id].present?

      attrs[:start_time] = reformat_date_and_time(attrs[:start_time], attrs.delete(:start_hr), attrs.delete(:start_min), attrs.delete(:start_sec))
      attrs[:end_time] = reformat_date_and_time(attrs[:end_time], attrs.delete(:end_hr), attrs.delete(:end_min), attrs.delete(:end_sec))

      file = DataFile.find(id)

      successful_update = file.update_attributes(attrs)
      successful_complete_update &= successful_update
      unless successful_update
        file.add_message(:failed, file.errors.full_messages.join(", "))
        @uploaded_files << file
      end

    end

    if successful_complete_update
      redirect_to root_path, :notice => "File metadata updated successfully"
    else
      render :create
    end

  end

  def download
    unless @data_file.published? and @data_file.is_package?
      authenticate_user!
      authorize! :download, @data_file
    end
    send_data_file(@data_file)
  end

  def download_selected
    if current_user.data_files.empty?
      redirect_to(data_files_path, :notice => "Your cart is empty.")
    else
      ids = current_user.data_files.collect(&:id)
      unless ids.empty?
        if ids.size == 1
          send_data_file(DataFile.find(ids.first))
        else
          send_zip(ids)
        end
      else
        redirect_to(:back||data_files_path)
      end
    end
  end

  def destroy
    file = DataFile.find(params[:id])
    if file.is_package?
      if file.destroy
        begin
          if archive_files(file)
            redirect_to(data_files_path, :notice => "The file '#{file.filename}' was successfully archived.")
          end
        rescue Errno::ENOENT
          redirect_to(data_files_path, :alert => "The file '#{file.filename}' was successfully removed but the files itself could not be archived. \nPlease copy this entire error for your system administrator.")
        end
      else
        redirect_to(data_file_path(file), :alert => "Could not delete this file. It may have an ID assigned, or you may not have permission to delete it.")
      end
    else
      if file.destroy
        begin
          File.delete @data_file.path
          redirect_to(data_files_path, :notice => "The file '#{file.filename}' was successfully removed.")
        rescue Errno::ENOENT
          redirect_to(data_files_path, :alert => "The file '#{file.filename}' was successfully removed from the system, however the file itself could not be deleted. \nPlease copy this entire error for your system administrator.")
        end
      else
        redirect_to(data_file_path(file), :alert => "Could not delete this file. It may have an ID assigned, or you may not have permission to delete it.")
      end
    end
  end

  def api_search
    do_api_search(params)
  end

  private

  def send_data_file(data_file)
    extname = File.extname(data_file.filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(extname)
    content_type = mime_type.to_s unless mime_type.nil?

    file_params = {:filename => data_file.filename}
    file_params[:type] = content_type if content_type
    send_file data_file.path, file_params
  end

  def cleanout_cart_items
    file_id = params[:id]
    CartItem.where(:data_file_id == file_id).each do |item|
      item.destroy if item.user_id.eql?(current_user.id)
    end
  end

  def reformat_date_and_time(date, hr, min, sec)
    return if date.blank?
    adjusted_date = date #so we can use << without modifying the original
    if hr.present? && min.present? && sec.present?
      adjusted_date << " " << hr << ":" << min << ":" << sec
    end
    return adjusted_date << "UTC"
  end

  def do_search(search_params)
    @search = DataFileSearch.new(search_params)

    @data_files = @search.do_search(@data_files)

    @from_date = @search.search_params[:from_date]
    @to_date = @search.search_params[:to_date]
    @selected_facilities = @search.facilities
    @selected_experiments = @search.experiments
    @selected_variables = @search.variables
    @selected_parent_variables = @search.variable_parents
    @filename = @search.filename
    @description = @search.description
    @file_id = @search.file_id
    @id = @search.id
    @selected_stati = @search.stati
    @selected_tags = @search.tags
    @uploader_id = @search.uploader_id
    @upload_from_date = @search.search_params[:upload_from_date]
    @upload_to_date = @search.search_params[:upload_to_date]
    @published = @search.published
    @unpublished = @search.unpublished
    @published_date = @search.published_date

    # apply any sorting to the scope we've built up so far
    # prefix the sort column with the table name so we don't get ambiguity errors when doing joins
    col = sort_column
    col = "data_files.#{col}" unless col.index(".")
    if col == "users.email"
      @data_files = @data_files.joins(:created_by).order(col + ' ' + sort_direction)
    elsif col == "data_files.experiment_id"
      @data_files = @data_files.joins(:experiment).order("experiments.name" + ' ' + sort_direction)
    else
      @data_files = @data_files.order(col + ' ' + sort_direction)
    end
    @unadded_items = false
    @data_files.each do |data_file|
      unless current_user.data_file_in_cart?(data_file)
        @unadded_items = true
      end
    end

    if @search.error
      flash.now[:alert] = @search.error
    end
  end

  def do_api_search(search_params)
    @search = DataFileSearch.new(search_params)
    @data_files = @search.do_search(@data_files)
    @data_files.each do |data_file|
      data_file.url = download_data_file_url(data_file.id)
    end
  end

  def validate_inputs(files, experiment_id, type, description, tags)
    # we're creating an object to stick the errors on which is kind of weird, but works since we're creating more than one file so don't have a single object already
    @data_file = DataFile.new
    @data_file.errors.add(:base, "Please select an experiment") if experiment_id.blank?
    @data_file.errors.add(:base, "Please select the file type") if type.blank?
    @data_file.errors.add(:base, "Please select at least one file to upload") if files.blank?
    @data_file.experiment_id = experiment_id
    @data_file.file_processing_status = type
    @data_file.file_processing_description = description
    @data_file.tag_ids = tags
    !@data_file.errors.any?
  end

  def validate_api_inputs(file, type, experiment_id, tag_names)
    errors = []
    errors << 'Experiment id is required' if experiment_id.blank?
    errors << 'File is required' if file.blank?
    errors << 'File type is required' if type.blank?
    errors << 'File type not recognised' unless type.blank? || DataFile::STATI.include?(type)
    errors << 'Supplied experiment id does not exist' unless experiment_id.blank? || Experiment.exists?(experiment_id)
    errors << 'Supplied file was not a valid file' unless file.blank? || file.is_a?(ActionDispatch::Http::UploadedFile)

    tag_ids = parse_tags(tag_names, errors)
    [errors, tag_ids]
  end

  def parse_tags(tag_names, errors)
    return [] if tag_names.blank?
    tag_ids = []
    begin
      tag_names_array = CSV.parse_line(tag_names)
      tag_names_array.each do |tag_name|
        tag = Tag.find_by_name(tag_name)
        if tag
          tag_ids << tag.id
        else
          errors << "Unknown tag '#{tag_name}'"
        end
      end
    rescue CSV::MalformedCSVError
      errors << 'Incorrect format for tags - tags must be double-quoted and comma separated'
    end
    tag_ids
  end

  def sort_column
    ALLOWED_SORT_PARAMS.include?(params[:sort]) ? params[:sort] : "data_files.created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def parse_date(string)
    return nil if string.blank?
    Date.parse(string)
  end

  def send_zip(ids)
    files = DataFile.find(ids)
    first_file_name = files.collect(&:filename).sort.first
    download_file_name = "#{first_file_name}.zip"
    CustomDownloadBuilder.zip_for_files(files) do |zip_file|
      send_file zip_file.path, :type => 'application/zip', :disposition => 'attachment', :filename => download_file_name
    end
  end

  def send_bagit(ids)
    CustomDownloadBuilder.bagit_for_files_with_ids(ids) do |zip_file|
      send_file zip_file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "download_selected.zip"
    end
  end

  def sort_params
    if params["sort"]
      session["sort"] = params["sort"]
      session["direction"] = params["direction"]
    elsif session["sort"]
      params["sort"] = session["sort"]
      params["direction"] = session["direction"]
    end
  end

  def search_params
    if params["search"]
      session["search"] = params["search"]
    elsif session["search"]
      params["search"] = session["search"]
    end
  end

  def page_params
    if params["page"]
      session["page"] = params["page"]
    elsif session["page"]
      params["page"] = session["page"]
    end
  end

  def clean_up_temp_files(files)
    # removes RackMultipart from /tmp
    files.each do |file|
      if file.is_a? ActionDispatch::Http::UploadedFile
        tempfile = file.tempfile.path
        FileUtils.remove_entry_secure tempfile if File::exists?(tempfile)
      end
    end
  end

  def archive_files(data_file)
    archive_dir = APP_CONFIG['archived_data_directory']
    Dir.mkdir(archive_dir) unless Dir.exists?(archive_dir)
    package_dir = File.join(archive_dir, data_file.id.to_s)
    Dir.mkdir(package_dir) unless Dir.exists?(package_dir)
    archive_rif_cs(data_file, package_dir) && archive_data(data_file, package_dir) ? true : false
  end

  def archive_rif_cs(data_file, package_dir)
    published_dir = APP_CONFIG['published_rif_cs_directory']
    unpublished_dir = APP_CONFIG['unpublished_rif_cs_directory']
    file = "rif-cs-#{data_file.id}.xml"
    archive_location = File.join(package_dir, file)

    if data_file.is_published?
      published_location = File.join(published_dir, file)
      FileUtils.mv published_location, archive_location, :verbose => true
    else
      unpublished_location = File.join(unpublished_dir, file)
      FileUtils.mv unpublished_location, archive_location, :verbose => true
    end
    true
  end

  def archive_data(data_file, package_dir)
    archive_location = File.join(package_dir, data_file.filename)
    FileUtils.mv(@data_file.path, archive_location)
    true
  end

end
