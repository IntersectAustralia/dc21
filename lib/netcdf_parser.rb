require 'nokogiri'

class NetcdfParser

  def self.extract_metadata(data_file)
    data_file_attrs, column_details_attrs, metadata_items_as_hash = read_metadata(data_file)

    data_file.update_attributes! data_file_attrs

    column_details_attrs.each do |attrs|
      data_file.column_details.create!(attrs)
    end

    metadata_items_as_hash.each do |k, v|
      data_file.add_metadata_item(k, v)
    end
  end

  private

  def self.read_metadata(data_file)
    # Retrieve column information
    datafile_path = Shellwords.shellescape(data_file.path)
    util = NetcdfUtilities.new(datafile_path)

    # Retrieve file metadata
    metadata_items = get_data_file_metadata(util)

    # Retrieve DataFile attributes
    data_file_attrs = get_data_file_attributes(util)

    # Retrieve column info
    col_info = get_data_file_column_details(util)

    return data_file_attrs, col_info, metadata_items
  end

  private

  def self.get_data_file_attributes(util)
    data_file_attrs = {}
    id = util.extract_external_id
    start_time, end_time = util.extract_start_end_time
    data_file_attrs[:external_id] = util.formatted_id(id, start_time, end_time)
    data_file_attrs[:start_time] = start_time
    data_file_attrs[:end_time] = end_time

    data_file_attrs
  end

  def self.get_data_file_column_details(util)
    variables = util.extract_all_variables
    col_info = []
    variables.each_with_index do |var, index|
      name = util.extract_attribute_from_element(var, 'name')
      unit = util.extract_attribute_from_variable(var, 'units')
      data_type = util.extract_attribute_from_variable(var, 'cell_methods')
      fill_value = util.extract_attribute_from_variable(var, '_FillValue')
      col_info << {:name => name.blank? ? nil : name,
                   :unit => unit.blank? ? nil : unit,
                   :data_type => data_type.blank? ? nil : data_type,
                   :fill_value => fill_value.blank? ? nil : fill_value,
                   :position => index}
    end
    col_info
  end

  def self.get_data_file_metadata(util)

    metadata_items = {}
    dimensions = util.extract_all_dimensions
    dimensions.each do |dim|
      name = util.extract_attribute_from_element(dim, 'name')
      value = util.extract_attribute_from_element(dim, 'length')
      metadata_items[name] = value
    end

    top_lvl_attrs = util.extract_all_top_lvl_attributes
    top_lvl_attrs.each do |attr|
      name = util.extract_attribute_from_element(attr, 'name')
      value = util.extract_attribute_from_element(attr, 'value')
      metadata_items[name] = value
    end

    metadata_items
  end

end