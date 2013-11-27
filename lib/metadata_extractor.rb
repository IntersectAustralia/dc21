class MetadataExtractor

  def extract_metadata(data_file, type, force=false)
    config = SystemConfiguration.instance
    if type == FileTypeDeterminer::TOA5
      Toa5Parser.extract_metadata(data_file)
    elsif config.auto_ocr?(data_file, force)
      data_file.transfer_status = DataFile::RESQUE_QUEUED
      data_file.uuid = OCRWorker.create({:data_file_id => data_file.id})
      data_file.save
    elsif config.auto_sr?(data_file, force)
      data_file.transfer_status = DataFile::RESQUE_QUEUED
      data_file.uuid = SRWorker.create({:data_file_id => data_file.id})
      data_file.save
    end
  end

end
