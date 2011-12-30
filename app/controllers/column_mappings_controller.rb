class ColumnMappingsController < ApplicationController

  set_tab :admin

  def index
    @column_mappings = ColumnMapping.all
  end

  def new
  end
  
end
