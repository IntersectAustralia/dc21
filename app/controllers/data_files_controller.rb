class DataFilesController < ApplicationController

  before_filter :authenticate_user!
  load_and_authorize_resource
  set_tab :home

  def index
    set_tab :explore, :contentnavigation
    @data_files = @data_files.most_recent_first
  end

  def show
    
  end

  def new

  end


end
