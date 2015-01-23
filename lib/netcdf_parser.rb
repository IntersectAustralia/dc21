require 'nokogiri'

class NetcdfParser

  def self.extract_metadata(data_file)
    column_details_attrs = read_metadata(data_file)
    column_details_attrs.each do |attrs|
      data_file.column_details.create!(attrs)
    end
  end

  private

  def self.read_metadata(data_file)
    # Get header data
    datafile_path = Shellwords.shellescape(data_file.path)
    output = %x(ncdump -x -h #{datafile_path})
    doc = Nokogiri::XML.parse(output)
    doc.remove_namespaces!
    results = doc.xpath('//variable')
    col_info = []
    results.each_with_index do |variable, index|
      name = variable.xpath('./@name').text
      unit = variable.xpath('./attribute[@name="units"]/@value').text
      data_type = variable.xpath('./attribute[@name="cell_methods"]/@value').text
      col_info << {:name => name.blank? ? nil : name,
                   :unit => unit.blank? ? nil : unit,
                   :data_type => data_type.blank? ? nil : data_type,
                   :position => index}
    end
    col_info
  end




end