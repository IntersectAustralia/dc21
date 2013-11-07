class MetadataExtractor

  def extract_metadata(data_file, type)
    if type == FileTypeDeterminer::TOA5
      Toa5Parser.extract_metadata(data_file)
    elsif FileTypeDeterminer::OCR_TYPES.include?(type)
      data_file.transfer_status = DataFile::RESQUE_QUEUED
      data_file.uuid = OCRWorker.create({:data_file_id => data_file.id})
      data_file.save
    end
  end

end
