class AttachmentBuilder

  def initialize(files_root, current_user, file_type_determiner, metadata_extractor)
    @files_root = files_root
    @current_user = current_user
    @file_type_determiner = file_type_determiner
    @metadata_extractor = metadata_extractor
  end

  def build(file, experiment_id, type, description, tags=[])
    path, new_filename = store_file(file)
    data_file = create_data_file(path, new_filename, experiment_id, type, description, tags, file.original_filename, file.size)
    if data_file.messages.blank?
      data_file.add_message(:success, "File uploaded successfully.")
    end
    data_file
  end

  private

  def create_data_file(path, filename, experiment_id, type, description, tags, original_filename, size)
    Rails.logger.info("Processing: #{path} - #{filename}")

    data_file = DataFile.new(:path => path,
                             :filename => filename,
                             :created_by => @current_user,
                             :file_processing_status => type,
                             :experiment_id => experiment_id,
                             :file_processing_description => description,
                             :file_size => size)
    data_file.tag_ids = tags

    format = @file_type_determiner.identify_file(data_file)
    data_file.format = format

    data_file.save!
    @metadata_extractor.extract_metadata(data_file, format) if format
    data_file.reload

    bad_overlap = data_file.check_for_bad_overlap
    unless bad_overlap
      replaced_filenames = data_file.destroy_safe_overlap
      # if we renamed the file, but then deleted the file it clashed with, rename it back
      if replaced_filenames.include?(original_filename) and (filename != original_filename)
        data_file.rename_to(File.join(@files_root, original_filename), original_filename)
      end
    end

    if data_file.filename != original_filename
      data_file.add_message(:info, "A file already existed with the same name. File has been renamed.")
    end

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
    next_number = SequenceHelper.next_available(numbers)

    if ext.blank?
      original + "_#{next_number}"
    else
      "#{name}_#{next_number}.#{ext[1..-1]}"
    end
  end

end
