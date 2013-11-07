class FileTypeDeterminer

  TOA5 = "TOA5"
  BAGIT = "BAGIT"
  OCR_TYPES = %w{image/jpeg image/png}

  def identify_file(data_file)
    return TOA5 if is_toa5?(data_file)
    return BAGIT if is_bagit?(data_file)
    mime = File.mime_type?(data_file.path)
    unless mime[/unknown/]
      return mime
    end

    return nil
  end

  private

  def is_toa5?(data_file)
    return false unless File.exists?(data_file.path)
    File.open(data_file.path) do |file|
      header = file.read(10) # read just the first bit so we can check for the TOA5 in the header
      return false if header.blank?
      !header.match(/^"?TOA5/).nil?
    end
  end

  private

  def is_bagit?(data_file)
    return false unless File.exists?(data_file.path)
    data_file.file_processing_status.eql?('PACKAGE')
  end
end
