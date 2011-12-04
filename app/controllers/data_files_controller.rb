class DataFilesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource

  def index
    @data_files = @data_files.most_recent_first
  end

  def show
    
  end


end
