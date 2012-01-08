class ColumnMappingsController < ApplicationController

  before_filter :authenticate_user!
  set_tab :admin

  def index
    @column_mappings = ColumnMapping.all
  end

  def new
    @column_mappings = []
    5.times { @column_mappings << ColumnMapping.new }
  end

  def create
    errors = []
    @messages = []
    blank = []
    a = 0
    @column_mappings = []
    params[:column_mappings].each_value do |map|
      if !map.values.all?(&:blank?)
        @column_mapping = ColumnMapping.new(map)
        @column_mappings.push(@column_mapping)
        unless @column_mapping.valid?
          @column_mapping.errors.full_messages.each do |err_message|
            @messages << err_message
            errors << "#{a}"
          end
        end
        if @column_mapping.check_code_exists?(@column_mappings)
          @messages << "Can't add column mappings with the same code"
          errors << "#{a}"
        end
      else
        blank << "#{a}"
      end
      a = a + 1
    end
    if !errors.empty?
      render :action => 'new'
      return
    elsif blank.size == a
     @messages << "No column mapping information provided"
      render 'new'
      return
    end
    @column_mappings.each do |mapping|
      mapping.save unless mapping.nil?
    end
    flash[:notice] = "Column mappings successfully added"
    redirect_to column_mappings_path
  end

  def destroy
    @column_mapping = ColumnMapping.find(params[:id])
    @column_mapping.destroy
    redirect_to column_mappings_path, :notice => "The file was successfully deleted"
  end
  
end
