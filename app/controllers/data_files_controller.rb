class DataFilesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource
  set_tab :home
  helper_method :sort_column, :sort_direction

  expose(:tags) { Tag.order(:name) }
  expose(:facilities) { DataFile.searchable_facilities }
  expose(:variables) { DataFile.searchable_column_names }

  def index
    set_tab :explore, :contentnavigation
    @search = DataFileSearch.new(params[:search])

    # prefix the sort column with the table name so we don't get ambiguity errors when doing joins
    col = sort_column
    col = "data_files.#{col}" unless col.index(".")
    @data_files = DataFile.joins(:created_by).order(col + ' ' + sort_direction)
    @data_files = @search.do_search(@data_files)

    @from_date = @search.search_params[:from_date]
    @to_date = @search.search_params[:to_date]
    @selected_facilities = @search.facilities
    @selected_variables = @search.variables
    @filename = @search.filename
    @description = @search.description
    @selected_stati = @search.stati
    @selected_tags = @search.tags

    if @search.error
      flash.now[:alert] = @search.error
    end

  end

  def show
    set_tab :explore, :contentnavigation
    @column_mappings = ColumnMapping.all
  end

  def new
    @uploaded_files = []
  end

  def edit
  end

  def update
  end

  def create
    files = params[:files]
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
    params[:files].each do |id, attrs|
      file = DataFile.find(id)
      file.update_attributes(attrs)
    end

    redirect_to root_path, :notice => "File metadata updated successfully"
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

    temp_dir = Dir.mktmpdir
    paths = []
    @files.each do |file|
      if file.has_data_in_range?(date_range.from_date, date_range.to_date)
        paths << Toa5Subsetter.extract_matching_rows_to(file, temp_dir, @from_date, @to_date)
      end
    end

    if paths.empty?
      flash.now[:alert] = "There is no data available for the date range you entered."
      render :build_download
      return
    end

    zip_file = Tempfile.new("temp_file")
    ZipBuilder.build_zip(zip_file, paths)
    send_file zip_file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "custom_download.zip"
    zip_file.close
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
    if params[:sort] == "users.email"
      "users.email"
    else
      @data_files.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
    end
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

  def parse_date(string)
    return nil if string.blank?
    Date.parse(string)
  end

  def send_zip(ids)
    file_paths = DataFile.find(ids).collect(&:path)

    zip_file = Tempfile.new("temp_file")
    ZipBuilder.build_zip(zip_file, file_paths)
    send_file zip_file.path, :type => 'application/zip', :disposition => 'attachment', :filename => "download_selected.zip"
    zip_file.close
  end

end
