class OverlapChecker
  def initialize(data_file, original_filename, files_root)
    @data_file = data_file
    @original_filename = original_filename
    @files_root = files_root
  end

  def run
    return unless @data_file.format == FileTypeDeterminer::TOA5 && @data_file.file_processing_status == DataFile::STATUS_RAW

    station_item = @data_file.metadata_items.find_by_key MetadataKeys::STATION_NAME_KEY
    table_item = @data_file.metadata_items.find_by_key MetadataKeys::TABLE_NAME_KEY
    return unless station_item && table_item

    # find files that need to be checked
    possible_files = @data_file.raw_toa5_files_with_same_station_name_and_table_name

    # categorise whether they overlap safely, unsafely or not at all
    unsafe = []
    safe = []
    possible_files.each do |file|
      category = file.categorise_overlap(@data_file)
      unsafe << file if category == 'UNSAFE'
      safe << file if category == 'SAFE'
    end

    # check for bad overlaps first
    unless unsafe.empty?
      @data_file.add_message(:error, 'File cannot safely replace existing files. File has been saved with type ERROR. Overlaps with ' + unsafe.collect(&:filename).join(', '))
      @data_file.file_processing_status = DataFile::STATUS_ERROR
      @data_file.save!
      return # we don't continue to destroy safe if there's unsafe overlaps
    end

    # now look at destroying files we safely overlap with
    unless safe.empty?
      replaced_descriptions = safe.collect(&:file_processing_description)
      replaced_filenames = safe.collect(&:filename)
      @data_file.add_message(:info, "The file replaced one or more other files with similar data. Replaced files: #{replaced_filenames.join(", ")}")
      @data_file.file_processing_description = replaced_descriptions.join(', ') if @data_file.file_processing_description.blank?
      @data_file.save!
      safe.each { |df| df.destroy }

      # if we renamed the file, but then deleted the file it clashed with, rename it back
      if replaced_filenames.include?(@original_filename) and (@data_file.filename != @original_filename)
        @data_file.rename_to(File.join(@files_root, @original_filename), @original_filename)
      end
    end
  end
end