class MetadataExtractor

  def extract_metadata(data_file, type)
    if type == FileTypeDeterminer::TOA5
      Toa5Parser.extract_metadata(data_file)
    end
  end

end
