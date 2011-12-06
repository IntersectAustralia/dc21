class FileTypeDeterminer

  TOA5 = "TOA5"

  def identify_file(data_file)
    if is_toa5?(data_file)
      return [true, TOA5]
    end
    [false, nil]
  end

  private

  def is_toa5?(data_file)
    return false unless File.exists?(data_file.path)

    File.open(data_file.path) do |file|
      header = file.read(10) # read just the first bit so we can check for the TOA5 in the header
      return false if header.blank?
      !header.match(/^TOA5/).nil?
    end

  end
end