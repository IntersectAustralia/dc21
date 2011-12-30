class DataFilesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource
  set_tab :home
  helper_method :sort_column, :sort_direction

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

    if @search.error
      flash.now[:alert] = @search.error
    end

    @facilities = DataFile.searchable_facilities
    @variables = DataFile.searchable_column_names
  end

  def show
    set_tab :explore, :contentnavigation
    @column_mappings = ColumnMapping.all
  end

  def new
  end

  def create
    attachment_builder = AttachmentBuilder.new(params, APP_CONFIG['files_root'], current_user, FileTypeDeterminer.new, MetadataExtractor.new)
    result = attachment_builder.build()

    respond_to do |format|
      format.json { render :json => result }
    end
  end

  def verify_upload
    attachment_builder = AttachmentBuilder.new(params, APP_CONFIG['files_root'], current_user, nil, nil)

    result = attachment_builder.verify_from_filenames

    respond_to do |format|
      format.json { render :json => result }
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
    elsif !ids.nil?
      files = DataFile.find(ids)
      t= Tempfile.new("temp_file")
      Zip::ZipOutputStream.open(t.path) do |zos|
        files.each do |dfile|
          zos.put_next_entry("#{dfile.filename}")
          zos << File.open(dfile.path, 'rb') { |file| file.read }
        end
      end
      send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => "download_selected.zip"
      t.close
    end
  end

  private

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


end
