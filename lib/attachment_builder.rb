class AttachmentBuilder

  def initialize(files_root, current_user, file_type_determiner, metadata_extractor)
    @files_root = files_root
    @current_user = current_user
    @file_type_determiner = file_type_determiner
    @metadata_extractor = metadata_extractor
  end

  def build(file, experiment_id, type)
    path, new_filename = store_file(file)
    data_file = create_data_file(path, new_filename, experiment_id, type)
    if new_filename != file.original_filename
      data_file.messages = ["A file already existed with the same name. File has been renamed."]
    end
    data_file
  end

  private

  def create_data_file(path, filename, experiment_id, type)
    Rails.logger.info("Processing: #{path} - #{filename}")

    data_file = DataFile.new(:path => path, :filename => filename, :created_by => @current_user, :file_processing_status => type, :experiment_id => experiment_id)
    data_file.messages = ["File uploaded successfully"]

    format = @file_type_determiner.identify_file(data_file)
    data_file.format = format

    data_file.save!
    @metadata_extractor.extract_metadata(data_file, format) if format
    data_file
  end

  def store_file(file)
    filename = calculate_filename(file.original_filename)
    store_path = File.join(@files_root, filename)

    FileUtils.cp(file.path, store_path)

    [store_path, filename]
  end

  def calculate_filename(original)
    return original unless DataFile.find_by_filename(original)

    ext = File.extname(original)

    regex = if ext.blank?
              /\A#{Regexp.escape(original)}_(\d+)\Z/
            else
              name = original[0..(original.rindex(".") - 1)]
                  /\A#{Regexp.escape(name)}_(\d+)\.#{Regexp.escape(ext[1..-1])}\Z/
            end


    matching = DataFile.all.collect do |s|
      match = s.filename.match(regex)
      match ? match[1].to_i : nil
    end
    numbers = matching.compact.sort
    next_number = numbers.empty? ? 1 : (numbers.last + 1)

    if ext.blank?
      original + "_#{next_number}"
    else
      "#{name}_#{next_number}.#{ext[1..-1]}"
    end
  end

end
