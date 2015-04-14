require 'csv'

class DataFilesController < ApplicationController

  ALLOWED_SORT_PARAMS = %w(users.email data_files.filename data_files.created_at data_files.file_processing_status data_files.experiment_id data_files.file_size)
  SAVE_MESSAGE = 'The data file was saved successfully.'

  before_filter :authenticate_user!, :except => [:download]
  before_filter :sort_params, :only => [:index, :search]
  before_filter :search_params, :only => [:index, :search]
  before_filter :page_params, :only => [:index]
  before_filter :clean_up_temp_image_files

  load_and_authorize_resource :except => [:download, :api_search, :variable_list]
  load_resource :only => [:download]
  set_tab :home
  helper_method :sort_column, :sort_direction
  layout 'data_files'

  expose(:tags) { Tag.order(:name) }
  expose(:labels) { Label.joins(:data_file_labels).pluck(:name).uniq }
  expose(:access_groups) { AccessGroup.pluck(:name).uniq }
  expose(:facilities) { Facility.order(:name).select([:id, :name]).includes(:experiments) }
  expose(:variables) { ColumnMapping.mapped_column_names_for_search }

  def index
    set_tab :explore, :contentnavigation
    do_search(params[:search])
    @data_files_paginated = @data_files.paginate(page: params[:page]).search_display_fields
  end

  def search
    session[:page] = nil
    set_tab :explore, :contentnavigation
    do_search(params[:search])
    @data_files_paginated = @data_files.paginate(page: params[:page]).search_display_fields
    render :index
  end

  def clear
    session["search"] = nil
    set_tab :explore, :contentnavigation
    do_search(params[:search])
    @data_files_paginated = @data_files.paginate(page: params[:page]).search_display_fields
    render :index
  end

  def show
    set_tab :explore, :contentnavigation
    @back_request = request.referer
    @data_file = DataFile.find_by_id(params[:id])
    if ['image/jpeg','image/bmp','image/x-windows-bmp','image/gif','image/png','image/x-ms-bmp'].include? @data_file.format
      FileUtils.cp_r @data_file.path, Rails.root.join('public/images/temp/')
      @path = '/images/temp/' + @data_file.filename
    end
  end

  def new
    @uploaded_files = []
    # set_tab :dashboard, :contentnavigation
  end

  def edit
    if !@data_file.modifiable? and !current_user.is_admin?
      redirect_to data_file_path(@data_file), alert: "Cannot edit - Creation status is not COMPLETE."
      return
    end
    set_tab :explore, :contentnavigation
  end

  def update
    if !@data_file.modifiable? and !current_user.is_admin?
      redirect_to data_file_path(@data_file), alert: "Cannot edit - Creation status is not COMPLETE."
      return
    end

    @data_file.tag_ids = params[:tags]


    if !params[:date].nil?
      attrs = params.delete(:date)
      start_time = reformat_date_and_time(attrs[:start_time], attrs[:start_hr], attrs[:start_min], attrs[:start_sec])
      end_time = reformat_date_and_time(attrs[:end_time], attrs[:end_hr], attrs[:end_min], attrs[:end_sec])
      params[:data_file][:start_time] = start_time
      params[:data_file][:end_time] = end_time
    end

    if params[:data_file][:parent_ids]
      params[:data_file][:parent_ids] = params[:data_file][:parent_ids].split(",")
    end
    if params[:data_file][:child_ids]
      params[:data_file][:child_ids] = params[:data_file][:child_ids].split(",")
    end

    if params[:data_file][:access_groups]
      params[:data_file][:access_groups] = params[:data_file][:access_groups].map {|id| AccessGroup.find_by_id(id)}
    end

    old_filename = @data_file.filename
    if @data_file.update_attributes(params[:data_file])
      @data_file.rename_file(old_filename, params[:data_file][:filename], APP_CONFIG['files_root']) unless @data_file.is_package?
      redirect_to data_file_path(@data_file), notice: SAVE_MESSAGE
    else
      render action: "edit"
    end

  end

  def create
    begin
      files = []
      params[:files].each { |file_group| files << file_group } if params[:files].is_a?(Array)

      experiment_id = params[:data_file][:experiment_id]
      description = params[:description]
      type = params[:file_processing_status]
      tags = params[:tags]
      l = params[:data_file].delete(:label_list)
      labels = l.split(',').map{|name| Label.find_or_create_by_name(name).id}

      parents = []
      if params[:data_file][:parent_ids]
        parents = params[:data_file][:parent_ids].split(",")
      end

      access_groups = []
      if params[:data_file][:access_groups]
        access_groups = params[:data_file][:access_groups].map {|id| AccessGroup.find_by_id(id)}
      end

      unless validate_inputs(files, experiment_id, type, description, tags, labels, access_groups)
        render :new
        return
      end

      @uploaded_files = []
      attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], current_user, FileTypeDeterminer.new, MetadataExtractor.new)
      @error_messages = []
      files.each do |file|
        begin
          @uploaded_files << attachment_builder.build(file, experiment_id, type, description, tags, labels, parents)
        rescue Exception => e
          @error_messages << e.message
        end
      end
      if (not @error_messages.empty?) and (files.length == 1)
        files = []
        redirect_to :back, :flash => { :error => @error_messages }
      end
    ensure
      clean_up_temp_files(files)
    end

  end

  def process_metadata_extraction
    MetadataExtractor.new.extract_metadata(@data_file, @data_file.format, current_user, true)
    redirect_to data_file_path(@data_file), :notice => "Data file has been queued for processing."
  end

  def bulk_update
    successful_complete_update = true
    @uploaded_files = []

    params[:files].each do |id, attrs|

      if attrs[:start_time]
        attrs.merge!(params[:date][:files][id]) if params[:date].present? && params[:date][:files][id].present?
        attrs[:start_time] = reformat_date_and_time(attrs[:start_time], attrs.delete(:start_hr), attrs.delete(:start_min), attrs.delete(:start_sec))
        attrs[:end_time] = reformat_date_and_time(attrs[:end_time], attrs.delete(:end_hr), attrs.delete(:end_min), attrs.delete(:end_sec))
      end

      if attrs[:parent_ids]
        attrs[:parent_ids] = attrs[:parent_ids].split(",")
      end

      if attrs[:access_groups]
        array_of_access_groups = attrs[:access_groups][:access_groups].map {|id| AccessGroup.find_by_id(id)}
        attrs[:access_groups] = array_of_access_groups
      end

      unless attrs[:access_to_user_groups]
        attrs[:access_to_user_groups] = false
      end

      unless attrs[:access_to_all_institutional_users]
        attrs[:access_to_all_institutional_users] = false
      end


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

  def download_selected
    size_before_authorised_check = cart_items.size
    cart_items.delete_if{|file| !file.is_authorised_for_access_by?(current_user)} if !cart_items.empty?
    if cart_items.size != size_before_authorised_check
      flash[:alert] = "#{size_before_authorised_check - cart_items.size} restricted access files were not downloaded because you do not have access."
    end

    if cart_items.empty?
      redirect_to(data_files_path, :notice => "Your cart is empty.")
    else
      response.headers['Cache-Control'] = "no-store, no-cache, max-age=0, must-revalidate"
      response.headers['Pragma'] = "no-cache"
      cookies[:fileDownload] = "true"
      if cart_items.count == 1
        send_data_file(cart_items.first)
      else
        send_zip(cart_items)
      end
    end
  end

  def download
    unless @data_file.published? and @data_file.is_package?
      authenticate_user!
      #authorize! :download, @data_file
    end

    if current_user.present?
      if @data_file.is_authorised_for_access_by?(current_user)
        return send_data_file(@data_file)
      else
        redirect_to data_files_path, alert: "You do not have access to download this file.", :status => 403
      end
    else
      unless APP_CONFIG['ip_addresses'].nil?
      if APP_CONFIG['ip_addresses'].include? request.ip
        return send_data_file(@data_file)
      else
        raise ActionController::RoutingError.new('Not Found')
      end
      else
      raise ActionController::RoutingError.new('Not Found')
      end
    end
  end

  def destroy

    if !@data_file.modifiable? and !current_user.is_admin?
      redirect_to data_file_path(@data_file), alert: "Cannot delete - Creation status is not COMPLETE."
      return
    end

    if @data_file.is_package?
      if @data_file.destroy
        begin
          if archive_files(@data_file)
            redirect_to(data_files_path, :notice => "The file '#{@data_file.filename}' was successfully archived.")
          end
        rescue Errno::ENOENT => e
          Rails.logger.error e
          redirect_to(data_files_path, :alert => "The file '#{@data_file.filename}' was successfully removed but the files itself could not be archived. \nPlease copy this entire error for your system administrator.")
        end
      else
        redirect_to(data_file_path(@data_file), :alert => "Could not delete this file. It may have an ID assigned, or you may not have permission to delete it.")
      end
    else
      if @data_file.destroy
        begin
          File.delete @data_file.path
          redirect_to(data_files_path, :notice => "The file '#{@data_file.filename}' was successfully removed.")
        rescue Errno::ENOENT => e
          Rails.logger.error e
          redirect_to(data_files_path, :alert => "The file '#{@data_file.filename}' was successfully removed from the system, however the file itself could not be deleted. \nPlease copy this entire error for your system administrator.")
        end
      else
        redirect_to(data_file_path(@data_file), :alert => "Could not delete this file. It may have an ID assigned, or you may not have permission to delete it.")
      end
    end
  end

  def variable_list
    var_list = ColumnDetail.all
    var_list.each do |column_detail|
       mapping = ColumnMapping.find_by_code(column_detail.name)
       column_detail["mapping"] = mapping.name if not mapping.blank?
    end
    render :json => var_list.to_json
  end

  def api_search
    do_api_search(params)
  end

  def api_create
    begin
      attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], current_user, FileTypeDeterminer.new, MetadataExtractor.new)

      file = params[:file]
      type = params[:type]
      experiment_id = params[:org_level2_id] || params[:experiment_id]
      tag_names = params[:tag_names]
      label_names = params[:label_names]
      parent_files = clean_params_list_string(params[:parent_filenames])
      parent_file_ids = DataFile.where(:filename => parent_files).pluck(:id)
      access_groups = clean_params_list_string(params[:access_groups])
      access_group_ids = AccessGroup.where(:name => access_groups).pluck(:id)

      errors, tag_ids, label_ids, access, access_to_all_institutional_users, access_to_user_groups = validate_api_inputs(file, type, experiment_id, tag_names, label_names, params[:access], params[:access_to_all_institutional_users], params[:access_to_user_groups], params[:access_groups])

      if errors.empty?
        begin
          uploaded_file = attachment_builder.build(file, experiment_id, type, params[:description] || "", tag_ids, label_ids, parent_file_ids, [], access, access_to_all_institutional_users, access_to_user_groups, access_group_ids)
          messages = uploaded_file.messages.collect { |m| m[:message] }
        rescue Exception => e
          # Exit if attachment builder fails to build the uploaded file
          render :json => {:messages => e.message}, :status => :bad_request
          return
        end
        if !access_groups.nil? and access_groups.size != access_group_ids.size
          n = access_groups.size - access_group_ids.size
          if n == 1
            messages << "#{n} access group does not exist in the system"
          else
            messages << "#{n} access groups do not exist in the system"
          end
        end
        render :json => {:file_id => uploaded_file.id, :messages => messages, :file_name => uploaded_file.filename, :file_type => uploaded_file.file_processing_status}
      else
        render :json => {:messages => errors}, :status => :bad_request
      end
    ensure
      clean_up_temp_files([file])
    end
  end

  private

  def clean_params_list_string(params_str)
    list_str = params_str
    unless list_str.nil? or list_str.kind_of?(Array)
      list_str = list_str.gsub('[','').gsub(']','').split(',')
      list_str = list_str.map{|name| name.tr('"','').strip }
    end
    list_str
  end

  def send_data_file(data_file)
    extname = File.extname(data_file.filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(extname)
    content_type = mime_type.to_s unless mime_type.nil?

    file_params = {:filename => data_file.filename}
    file_params[:type] = content_type if content_type
    send_file data_file.path, file_params
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
    @selected_automation_stati = @search.automation_stati
    @selected_tags = @search.tags
    @selected_labels = @search.labels
    @selected_file_formats = @search.file_formats
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

    if @search.error
      flash.now[:alert] = @search.error
    end
  end

  def do_api_search(search_params)
    #authorize! :read, DataFile
    @search = DataFileSearch.new(search_params)
    # prevents CanCan loading the id search param
    @data_files = DataFile.scoped
    @data_files = @search.do_search(@data_files)
    @data_files.each do |data_file|
        data_file.url = download_data_file_url(data_file.id, :format => :json)
    end

  end

  def validate_inputs(files, experiment_id, type, description, tags, labels, access_groups)
    # we're creating an object to stick the errors on which is kind of weird, but works since we're creating more than one file so don't have a single object already
    @data_file = DataFile.new
    @data_file.errors.add(:base, "Please select an experiment") if experiment_id.blank?
    @data_file.errors.add(:base, "Please select the file type") if type.blank?
    @data_file.errors.add(:base, "Please select at least one file to upload") if files.blank?

    files.each do |file|
      @data_file.errors.add(:base, "Filename is too long (maximum is 200 characters)") if file.original_filename.length > 200
      @data_file.errors.add(:base, "Path is too long (maximum is 260 characters)") if APP_CONFIG['files_root'].length + file.original_filename.length > 260
    end

    @data_file.experiment_id = experiment_id
    @data_file.file_processing_status = type
    @data_file.file_processing_description = description
    @data_file.tag_ids = tags
    @data_file.label_ids = labels
    @data_file.access_group_ids = access_groups
    !@data_file.errors.any?
  end

  def validate_api_inputs(file, type, experiment_id, tag_names, label_names, access, access_to_all_institutional_users, access_to_user_groups, access_groups)
    errors = []
    errors << 'Experiment id is required' if experiment_id.blank?
    errors << 'File is required' if file.blank?
    errors << 'File type is required' if type.blank?
    errors << 'File type not recognised' unless type.blank? || DataFile::STATI.include?(type)
    errors << 'Supplied org level 2 id does not exist' unless experiment_id.blank? || Experiment.exists?(experiment_id)
    errors << 'Supplied file was not a valid file' unless file.blank? || file.is_a?(ActionDispatch::Http::UploadedFile)
    errors << "Supplied access was not valid: has to be either #{DataFile::ACCESS_PUBLIC} or #{DataFile::ACCESS_PRIVATE}" unless access.blank? || access == DataFile::ACCESS_PUBLIC || access == DataFile::ACCESS_PRIVATE
    errors << 'Supplied access_to_all_institutional_users was not valid: has to be either true or false' unless access_to_all_institutional_users.blank? || access_to_all_institutional_users =~ (/^(true|t|yes|y|1)$/i) || access_to_all_institutional_users =~ (/^(false|f|no|n|0)$/i)
    errors << 'Supplied access_to_user_groups was not valid: has to be either true or false' unless access_to_user_groups.blank? || access_to_user_groups =~ (/^(true|t|yes|y|1)$/i) || access_to_user_groups =~ (/^(false|f|no|n|0)$/i)

    tag_ids = parse_tags(tag_names, errors)
    label_ids = parse_labels(label_names, errors)
    access_to_all_institutional_users_flag = ''
    access_to_user_groups_flag = ''
    if access_to_all_institutional_users and access_to_all_institutional_users =~ (/^(true|t|yes|y|1)$/i)
      access = DataFile::ACCESS_PRIVATE
      access_to_all_institutional_users_flag = true
    else
      access_to_all_institutional_users_flag = false
    end
    if access_to_user_groups and access_to_user_groups =~ (/^(true|t|yes|y|1)$/i)
      access = DataFile::ACCESS_PRIVATE
      access_to_user_groups_flag = true
    else
      access_to_user_groups_flag = false
    end
    unless access_groups.nil?
      access = DataFile::ACCESS_PRIVATE
      access_to_user_groups_flag = true
    end
    access_to_all_institutional_users_flag = true if access.blank? and access_to_user_groups.blank? and access_groups.nil?
    access = access.blank? ? DataFile::ACCESS_PRIVATE : access

    [errors, tag_ids, label_ids, access, access_to_all_institutional_users_flag, access_to_user_groups_flag]
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

  def parse_labels(label_names, errors)
    return [] if label_names.blank?
    label_ids = []
    begin
      label_names_array = CSV.parse_line(label_names)
      label_names_array.each do |label_name|
        label_ids << Label.find_or_create_by_name(label_name).id
      end
    rescue CSV::MalformedCSVError
      errors << 'Incorrect format for labels - labels must be double-quoted and comma separated'
    end
    label_ids
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

  def send_zip(files)
    first_file_name = files.pluck(:filename).sort.first
    download_file_name = "#{first_file_name}.zip"
    CustomDownloadBuilder.zip_for_files(files) do |zip_file|
      send_file zip_file.path, :type => 'application/zip', :disposition => 'attachment', :filename => download_file_name
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
      FileUtils.mv published_location, archive_location
    else
      unpublished_location = File.join(unpublished_dir, file)
      FileUtils.mv unpublished_location, archive_location
    end
    true
  end

  def archive_data(data_file, package_dir)
    archive_location = File.join(package_dir, data_file.filename)
    FileUtils.mv(@data_file.path, archive_location)
    true
  end

  def clean_up_temp_image_files
    FileUtils.rm_rf Dir.glob(Rails.root.join('public/images/temp/*'))
  end
end
