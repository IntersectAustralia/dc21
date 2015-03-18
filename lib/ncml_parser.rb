class NcmlParser

  def self.extract_metadata(data_file)
    file = File.new(data_file.path)
    doc = Nokogiri::XML.parse(file)
    doc.remove_namespaces!
    location = doc.xpath('/netcdf/@location')
    data_file.add_metadata_item('location', location.text)
  end

end