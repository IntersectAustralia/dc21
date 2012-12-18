class ColumnMappingsController < ApplicationController

  #New/Create:
    #This is the manual / admin way to define a mapping. Builds a column mapping by
    #-specifying the name of the column in the data file (code)
    #-selecting a preconfigured name from a dropdown

  #Map/Connect:
    #This is the auto / user way to define a mapping from a data file. Builds a column mapping by:
      #-selecting an unmapped column from that file
      #-selecting a preconfigured name from a dropdown

  before_filter :authenticate_user!
  set_tab :admin
  set_tab :columnmappings, :contentnavigation
  layout 'admin'

  def index
    @column_mappings = ColumnMapping.all
  end

  def new
    @column_mappings = []
    10.times { @column_mappings << ColumnMapping.new }
  end

  def create
    errors = []
    @messages = []
    blank = []
    a = 0
    @column_mappings = []
    params[:column_mappings].each_value do |mapping|
      @column_mapping = ColumnMapping.new(mapping)
      @column_mappings.push(@column_mapping)
      if !mapping.values.all?(&:blank?)
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

  def map
    @column_mappings = []
    @data_file = DataFile.find_by_id(params[:id])
    @data_file.column_details.each do |col|
      if col.get_mapped_name.nil?
        @column_mappings << ColumnMapping.new(:code => col.name)
      end
    end
  end

  def connect
    @messages = []
    @column_mappings = []
    params[:column_mappings].each_value do |mapping|
        @column_mapping = ColumnMapping.new(mapping)
        @column_mappings.push(@column_mapping)
    end
    if !@messages.empty?
      render 'map'
      return
    end
    @column_mappings.each do |mapping|
      mapping.save unless mapping.nil?
    end
    flash[:notice] = "Column mappings successfully updated."
    redirect_to data_file_path(params[:id])
  end

  def destroy
    @column_mapping = ColumnMapping.find(params[:id])
    @column_mapping.destroy
    redirect_to column_mappings_path, :notice => "The mapping was successfully deleted."
  end
end
