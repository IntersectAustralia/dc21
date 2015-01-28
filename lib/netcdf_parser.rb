require 'nokogiri'

class NetcdfParser

  def self.extract_metadata(data_file)
    #data_file_attrs, column_details_attrs, metadata_items_as_hash = read_metadata(data_file)

    column_details_attrs = read_metadata(data_file)

    #data_file.update_attributes! data_file_attrs

    column_details_attrs.each do |attrs|
      data_file.column_details.create!(attrs)
    end

    #metadata_items_as_hash.each do |k, v|
    #  data_file.add_metadata_item(k, v)
    #end
  end

  private

  def self.read_metadata(data_file)
    # Retrieve column information
    datafile_path = Shellwords.shellescape(data_file.path)
    output = %x(ncdump -x -h #{datafile_path})
    doc = Nokogiri::XML.parse(output)
    doc.remove_namespaces!

    # Retrieve ID
    #id = doc.xpath('/netcdf/attribute[@name="id"]')
    #data_file_attrs = {}
    #data_file_attrs[:external_id] = id.xpath('./@value').text


    # Retrieve column info
    variables = doc.xpath('//variable')
    col_info = []
    variables.each_with_index do |variable, index|
      name = variable.xpath('./@name').text
      unit = variable.xpath('./attribute[@name="units"]/@value').text
      data_type = variable.xpath('./attribute[@name="cell_methods"]/@value').text
      frequency = data_type # TODO: Change this when we know what to do here
      col_info << {:name => name.blank? ? nil : name,
                   :unit => unit.blank? ? nil : unit,
                   :data_type => data_type.blank? ? nil : data_type,
                   :frequency => frequency.blank? ? nil : frequency,
                   :position => index}
    end
    # Retrieve file information
    #top_lvl_attrs = doc.xpath('/netcdf/attribute')
    #metadata_items = {}
    #top_lvl_attrs.each do |attr|
    #  value = attr.xpath('./@value').text
    #  if value.length <= 255
    #    metadata_items[attr.xpath('./@name').text] = value
    #  end
    #end

    #return data_file_attrs, col_info, metadata_items
    col_info
  end

end