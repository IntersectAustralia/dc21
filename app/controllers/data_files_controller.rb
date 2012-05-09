class DataFilesController < ApplicationController

  ALLOWED_SORT_PARAMS = %w(users.email data_files.filename data_files.created_at data_files.file_processing_status data_files.experiment_id)
  SAVE_MESSAGE = 'The data file was saved successfully.'

  before_filter :authenticate_user!
  load_and_authorize_resource
  set_tab :home
  helper_method :sort_column, :sort_direction

  expose(:tags) { Tag.order(:name) }
  expose(:facilities) { Facility.order(:name) }
  expose(:variables) { ColumnMapping.mapped_column_names_for_search }
  expose(:experiments)  { Experiment.order(:name) }

  def index
    set_tab :explore, :contentnavigation
    do_search(params[:search])
  end

  def search
    set_tab :explore, :contentnavigation
    do_search(params[:search])
    render :index
  end

  def show
    set_tab :explore, :contentnavigation
    @column_mappings = ColumnMapping.all
  end

  def new
    @uploaded_files = []
    set_tab :dashboard, :contentnavigation
  end

  def edit
  end

  def update
    files = []
    params[:files].each { |file_group| files << file_group } if params[:files].is_a?(Array)

    tags = params[:tags]
    @data_file.tag_ids = tags

    if !params[:files].nil?
      params[:files].each do |id, attrs|
        attrs.merge!(params[:date][:files][id]) if params[:date].present? && params[:date][:files][id].present?
        start_time = reformat_date_and_time(attrs[:start_time], attrs[:start_hr], attrs[:start_min], attrs[:start_sec])
        end_time = reformat_date_and_time(attrs[:end_time], attrs[:end_hr], attrs[:end_min], attrs[:end_sec])
        @data_file.start_time = start_time
        @data_file.end_time = end_time
      end
    end

    success = false
    DataFile.transaction do
      success = @data_file.update_attributes(params[:data_file])
      raise ActiveRecord::Rollback unless success #tell AR to rollback the transaction but not pass on the error
    end

    if success
      redirect_to data_file_path, notice: SAVE_MESSAGE
    else
      render action: "edit"
    end
  end

  def create
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
  end

  def bulk_update
    successful_complete_update = true
    @uploaded_files = []

    params[:files].each do |id, attrs|

      attrs.merge!(params[:date][:files][id]) if  params[:date].present? && params[:date][:files][id].present?


      attrs[:start_time] = sanitise_date_and_time(attrs[:start_time], attrs.delete(:start_hr), attrs.delete(:start_min), attrs.delete(:start_sec))
      attrs[:end_time] = sanitise_date_and_time(attrs[:end_time], attrs.delete(:end_hr), attrs.delete(:end_min), attrs.delete(:end_sec))

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
    extname = File.extname(@data_file.filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(extname)
    content_type = mime_type.to_s unless mime_type.nil?

    file_params = {:filename => @data_file.filename}
    file_params[:type] = content_type if content_type
    send_file @data_file.path, file_params
  end

  def download_selected
    ids=params[:ids]
    if ids.nil?
      redirect_to(data_files_path, :alert => "No files were selected for download")
    else
      if params[:build_custom]
        redirect_to build_download_data_files_url(:ids => ids, :from_date => params[:searched_from_date], :to_date => params[:searched_to_date])
        return
      else
        send_zip(ids)
      end
    end
  end

  def build_download
    @ids = params[:ids]
    @files = DataFile.find(@ids)
    @from_date = params[:from_date]
    @to_date = params[:to_date]
    render :layout => 'guest'

  end

  def custom_download
    type = params[:type]
    @ids = params[:ids]
    @files = DataFile.find(@ids)
    @from_date = params[:from_date]
    @to_date = params[:to_date]

    if type == "all"
      send_zip(@ids)
      return
    end

    date_range = DateRange.new(@from_date, @to_date, false)
    unless date_range.valid?
      flash.now[:alert] = date_range.error
      render :build_download
      return
    end

    success = CustomDownloadBuilder.subsetted_zip_for_files(@files, date_range, @from_date, @to_date) do |zip_file|
      send_file zip_file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "custom_download.zip"
    end

    unless success
      flash.now[:alert] = "There is no data available for the date range you entered."
      render :build_download
    end
  end

  def destroy
    file = DataFile.find(params[:id])
    if file.destroy
      begin
        File.delete @data_file.path
        redirect_to(data_files_path, :notice => "The file '#{file.filename}' was successfully removed.")
      rescue Errno::ENOENT
        redirect_to(data_files_path, :alert => "The file '#{file.filename}' was successfully removed from the system, however the file itself could not be deleted. \nPlease copy this entire error for your system administrator.")
      end
    else
      redirect_to(show_data_file_path(file), :alert => "Could not delete this file (Do you have permission to delete it?)")
    end
  end

  private

  def sanitise_date_and_time(date, hr, min, sec)
    return if date.blank?
    adjusted_date = date #so we can use << without modifying the original
    if hr.present? && min.present? && sec.present?
      adjusted_date << " " << hr << ":" << min << ":" << sec
    end
    adjusted_date << " UTC"
    #puts "#{date} #{hr}:#{min}:#{sec} -> #{adjusted_date} -> #{DateTime.parse(adjusted_date)}"
    return DateTime.parse(adjusted_date)
  end

  def reformat_date_and_time(date, hr, min, sec)
    return if date.blank?
    adjusted_date = date #so we can use << without modifying the original
    if hr.present? && min.present? && sec.present?
      adjusted_date << " " << hr << ":" << min << ":" << sec
    end
    return adjusted_date
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
    @selected_stati = @search.stati
    @selected_tags = @search.tags
    @uploader_id = @search.uploader_id
    @upload_from_date = @search.search_params[:upload_from_date]
    @upload_to_date = @search.search_params[:upload_to_date]

    # apply any sorting to the scope we've built up so far
    # prefix the sort column with the table name so we don't get ambiguity errors when doing joins
    col = sort_column
    col = "data_files.#{col}" unless col.index(".")
    if col == "users.email"
      @data_files = @data_files.joins(:created_by).order(col + ' ' + sort_direction)
    elsif col == "data_files.experiment_id"
      # do experiment sorting in memory, since its too hard to do in the database with "Other" being -1
      @data_files = @data_files.sort_by(&:experiment_name)
      @data_files = @data_files.reverse if sort_direction == "desc"
    else
      @data_files = @data_files.order(col + ' ' + sort_direction)
    end

    if @search.error
      flash.now[:alert] = @search.error
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

  def default_layout
    "main"
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
    CustomDownloadBuilder.zip_for_files_with_ids(ids) do |zip_file|
      send_file zip_file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "download_selected.zip"
    end
  end

end
