class DataFilesController < ApplicationController

  before_filter :authenticate_user!, :except => [:create]
  load_and_authorize_resource :except => [:create]
  set_tab :home

  def index
    set_tab :explore, :contentnavigation
    @data_files = @data_files.most_recent_first
  end

  def show
  end

  def new
  end

  def create
    attachment_builder = AttachmentBuilder.new(params, APP_CONFIG['files_root'], nil, FileTypeDeterminer.new, MetadataExtractor.new)
    result = attachment_builder.build()

    respond_to do |format|
      format.json { render :json => result }
    end
  end

end
