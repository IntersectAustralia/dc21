class DataFilesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource
  set_tab :home
  helper_method :sort_column, :sort_direction  

  def index
    set_tab :explore, :contentnavigation
    @data_files = DataFile.joins(:created_by).order(sort_column + ' ' + sort_direction)
  end  

  def show
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

  def download
    extname = File.extname(@data_file.filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(extname)
    content_type = mime_type.to_s unless mime_type.nil?

    file_params = {:filename => @data_file.filename}
    file_params[:type] = content_type if content_type
    send_file @data_file.path, file_params
  end

  def search
    @searched = false
    if params[:date]
      @date = params[:date]
      date = parse_date(@date)
      if date
        @searched = true
        @data_files = DataFile.search_by_date(date)
        if @data_files.empty?
          @search_status_line = "No files found for #{date.to_s(:date_only)}."
        else
          @search_status_line = "Showing files containing data for #{date.to_s(:date_only)}."
        end

      end
    end
    render :index
  end

  private

  def parse_date(text)
    if params[:date].blank?
      flash.now[:alert] = "Please enter a date"
      return nil
    end

    begin
      Date.parse(text)
    rescue Exception
      flash.now[:alert] = "The date you entered was invalid. Please enter a valid date."
      nil
    end
  end

  def sort_column  
    if params[:sort] == "users.email"
      "users.email"
    else params[:sort] != "users.email"
      @data_files.column_names.include?(params[:sort]) ? params[:sort] : "id"
    end  
  end

  def sort_direction  
    %w[asc desc].include?(params[:direction]) ?  params[:direction] : "asc"  
  end  


end
