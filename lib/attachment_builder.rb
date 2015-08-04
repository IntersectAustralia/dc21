class AttachmentBuilder

  def initialize(files_root, current_user, file_type_determiner, metadata_extractor)
    @files_root = files_root
    @current_user = current_user
    @file_type_determiner = file_type_determiner
    @metadata_extractor = metadata_extractor
  end

  def build(file, experiment_id, type, description, tags = [], labels = [], parents = [], children=[], access = DataFile::ACCESS_PRIVATE, access_to_all_institutional_users = true, access_to_user_groups = false, access_groups = [], start_time = nil, end_time = nil)
    build_named_file(file.original_filename, file, experiment_id, type, description, tags, labels, parents, children, access, access_to_all_institutional_users, access_to_user_groups, access_groups, start_time, end_time)
  end


  def build_named_file(original_filename, file, experiment_id, type, description, tags = [], labels = [], parent_files = [], child_files = [], access, access_to_all_institutional_users, access_to_user_groups, access_groups, start_time, end_time)
    path, new_filename = store_file(original_filename, file)
    data_file = create_data_file(path, new_filename, experiment_id, type, description, tags, labels, original_filename, file.size, start_time, end_time, parent_files, child_files, access, access_to_all_institutional_users, access_to_user_groups, access_groups)
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

  def create_data_file(path, filename, experiment_id, type, description, tags, labels, original_filename, size, start_time, end_time, parent_file_ids, child_file_ids, access, access_to_all_institutional_users, access_to_user_groups, access_group_ids)
    Rails.logger.info("Processing: #{path} - #{filename}")

    data_file = DataFile.new(
                             :filename => filename,
                             :file_processing_status => type,
                             :experiment_id => experiment_id,
                             :file_processing_description => description,
                             :file_size => size)
    data_file.created_by = @current_user
    data_file.path = path
    data_file.tag_ids = tags
    data_file.label_ids = labels
    data_file.parent_ids = parent_file_ids
    data_file.child_ids = child_file_ids
    data_file.access = access
    data_file.access_to_all_institutional_users = access_to_all_institutional_users
    data_file.access_to_user_groups = access_to_user_groups
    data_file.access_group_ids = access_group_ids

    format = @file_type_determiner.identify_file(data_file)
    data_file.format = format
    if data_file.is_netcdf?
      check_netcdf_id_unique(data_file)
    end

    data_file.save!
    @metadata_extractor.extract_metadata(data_file, format) if format
    data_file.reload

    # Use the provided start_time and end_time if they were not parsed from the file's metadata
    if data_file.start_time.nil? && data_file.end_time.nil?
      data_file.start_time = start_time
      data_file.end_time = end_time
      data_file.save!
    end

    OverlapChecker.new(data_file, original_filename, @files_root).run

    if data_file.filename != original_filename
      data_file.add_message(:info, "A file already existed with the same name. File has been renamed.")
    end

    data_file
  end

  def check_netcdf_id_unique(data_file)
    util = NetcdfUtilities.new(data_file.path)
    eid = util.extract_external_id
    if eid.blank?
      eid = data_file.filename
    end
    start_time, end_time = util.extract_start_end_time
    id = util.formatted_id(eid, start_time, end_time)
    if not id.blank?
      raise Exception, "File with id #{id} already exists. Please choose another file." if DataFile.id_already_exist? id
    end
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
