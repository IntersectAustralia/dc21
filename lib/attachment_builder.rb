class AttachmentBuilder

  def initialize(files_root, current_user, file_type_determiner, metadata_extractor)
    @files_root = files_root
    @current_user = current_user
    @file_type_determiner = file_type_determiner
    @metadata_extractor = metadata_extractor
  end

  def build(file, experiment_id, type, description, tags = [], labels = [], parents = [], children=[])
    build_named_file(file.original_filename, file, experiment_id, type, description, tags, labels, parents, children, nil, nil)
  end


  def build_named_file(original_filename, file, experiment_id, type, description, tags = [], labels = [], parent_files = [], child_files = [], start_time, end_time)
    path, new_filename = store_file(original_filename, file)
    data_file = create_data_file(path, new_filename, experiment_id, type, description, tags, labels, original_filename, file.size, start_time, end_time, parent_files, child_files)
    if data_file.messages.blank?
      data_file.add_message(:success, "File uploaded successfully.")
    end
    data_file
  end

  def build_package(package, zip_file)
    store_package(package.filename, zip_file)
    package.file_size = zip_file.size
    package.save!
    to_a = []
    to_a << package
  end


  def build_output_data_file(parent, ext)
    tmp = Tempfile.new(["temp", ext])

    path, new_filename = store_file("#{parent.filename}#{ext}", tmp)

    data_file = DataFile.new(
                    :filename => new_filename,
                    :format => File.mime_type?(path),
                    :file_size => tmp.size,
                    :file_processing_status => "PROCESSED",
                    :experiment_id => parent.experiment_id)
    data_file.created_by = @current_user
    data_file.path = path
    data_file.transfer_status = DataFile::RESQUE_QUEUED
    data_file.save
    data_file
  end

  private

  def create_data_file(path, filename, experiment_id, type, description, tags, labels, original_filename, size, start_time, end_time, parent_file_ids, child_file_ids)
    Rails.logger.info("Processing: #{path} - #{filename}")

    data_file = DataFile.new(
                             :filename => filename,
                             :file_processing_status => type,
                             :experiment_id => experiment_id,
                             :file_processing_description => description,
                             :file_size => size,
                             :start_time => start_time,
                             :end_time => end_time)
    data_file.created_by = @current_user
    data_file.path = path
    data_file.tag_ids = tags
    data_file.label_ids = labels
    data_file.parent_ids = parent_file_ids
    data_file.child_ids = child_file_ids

    format = @file_type_determiner.identify_file(data_file)
    data_file.format = format

    data_file.save!
    @metadata_extractor.extract_metadata(data_file, format) if format
    data_file.reload

    OverlapChecker.new(data_file, original_filename, @files_root).run

    if data_file.filename != original_filename
      data_file.add_message(:info, "A file already existed with the same name. File has been renamed.")
    end

    data_file
  end

  def store_package(pkg_filename, data_file)
    store_path = File.join(@files_root, pkg_filename)
    FileUtils.cp(data_file.path, store_path)
    File.chmod(0644, store_path)
  end

  def store_file(original_filename, file)
    filename = calculate_filename(original_filename)
    store_path = File.join(@files_root, filename)

    FileUtils.cp(file.path, store_path)
    File.chmod(0644, store_path)
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
