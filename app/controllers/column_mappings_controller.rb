class ColumnMappingsController < ApplicationController

  before_filter :authenticate_user!
  set_tab :admin

  def index
    @column_mappings = ColumnMapping.all
  end

  def new
  end

  def destroy
    @column_mapping = ColumnMapping.find(params[:id])
    @column_mapping.destroy
    redirect_to column_mappings_path, :notice => "The file was successfully deleted"
  end
  
end
