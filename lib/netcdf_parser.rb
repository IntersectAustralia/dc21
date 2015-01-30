require 'nokogiri'

class NetcdfParser

  def self.extract_metadata(data_file)
    data_file_attrs, column_details_attrs, metadata_items_as_hash = read_metadata(data_file)

    begin
      data_file.update_attributes! data_file_attrs
    rescue
      # do nothing, FIXME DIVERBEVAN-52
    end

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

    output = %x(ncdump -x -h #{datafile_path})
    doc = Nokogiri::XML.parse(output)
    doc.remove_namespaces!

    # Retrieve file information
    metadata_items = get_data_file_metadata(doc)

    # Retrieve ID

    timevar_output = %x(ncks --xml -v time #{datafile_path})
    ncksdoc = Nokogiri::XML.parse(timevar_output)
    ncksdoc.remove_namespaces!
    data_file_attrs = get_data_file_attributes(doc, ncksdoc)

    # Retrieve column info
    col_info = get_data_file_column_details(doc)

    return data_file_attrs, col_info, metadata_items
  end

  private

  def self.get_data_file_attributes(doc, ncksdoc)
    id = doc.xpath('/netcdf/attribute[@name="id"]')
    data_file_attrs = {}
    data_file_attrs[:external_id] = id.xpath('./@value').text
    time_len = ncksdoc.xpath('//dimension/@length').text.to_i
    if time_len == 1
      value = ncksdoc.xpath('//variable/values').text
      value = value[0..-2] unless !value.ends_with? '.'
      time = Time.at(value.to_i)
      data_file_attrs[:start_time] = time
      data_file_attrs[:end_time] = time
    else
      # TODO DIVERBEVAN-53

    end
    data_file_attrs
  end

  def self.get_data_file_column_details(doc)
    variables = doc.xpath('//variable')
    col_info = []
    variables.each_with_index do |variable, index|
      name = variable.xpath('./@name').text
      unit = variable.xpath('./attribute[@name="units"]/@value').text
      data_type = variable.xpath('./attribute[@name="cell_methods"]/@value').text
      fill_value = variable.xpath('./attribute[@name="_FillValue"]/@value').text
      col_info << {:name => name.blank? ? nil : name,
                   :unit => unit.blank? ? nil : unit,
                   :data_type => data_type.blank? ? nil : data_type,
                   :fill_value => fill_value.blank? ? nil : fill_value,
                   :position => index}
    end
    col_info
  end

  def self.get_data_file_metadata(doc)

    metadata_items = {}
    dimensions = doc.xpath('//dimension')
    dimensions.each do |attr|
      name = attr.xpath('./@name').text
      value = attr.xpath('./@length').text
      metadata_items[name] = value
    end

    top_lvl_attrs = doc.xpath('/netcdf/attribute')
    top_lvl_attrs.each do |attr|
      value = attr.xpath('./@value').text
      metadata_items[attr.xpath('./@name').text] = value
    end

    metadata_items
  end

end