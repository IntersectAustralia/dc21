class FileTypeDeterminer

  TOA5 = "TOA5"
  NETCDF = "NETCDF"
  BAGIT = "BAGIT"
  UNKNOWN = "Unknown"
  # for searching file formats
  ALL_FORMATS = [TOA5, NETCDF, BAGIT, UNKNOWN] + EXTENSIONS.values.uniq

  def identify_file(data_file)
    return TOA5 if is_toa5?(data_file)
    return BAGIT if is_bagit?(data_file)
    return NETCDF if is_netcdf?(data_file)
    mime = File.mime_type?(File.new(data_file.path))
    unless mime[/unknown/]
      return mime[/^\w+\/[^;]+/]
    end

    return UNKNOWN
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

  def is_bagit?(data_file)
    return false unless File.exists?(data_file.path)
    data_file.file_processing_status.eql?('PACKAGE')
  end

  def is_netcdf?(data_file)
    return false unless File.exists?(data_file.path)
    datafile_path = Shellwords.shellescape data_file.path
    %x(ncdump -h #{datafile_path} &>/dev/null)
    return $?.success?
  end
end
