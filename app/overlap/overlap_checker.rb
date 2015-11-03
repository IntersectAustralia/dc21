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

    # find files that start no later than current end time and
    # end no earlier than current start time
    start_time = @data_file.start_time
    end_time = @data_file.end_time

    possible_files = possible_files.where('end_time >= ? AND start_time <= ?', start_time, end_time)
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
      replaced_parents = safe.collect(&:parent_ids).flatten
      replaced_children = safe.collect(&:child_ids).flatten
      @data_file.add_message(:info, "The file replaced one or more other files with similar data. Replaced files: #{replaced_filenames.join(", ")} ")

      # Determine the oldest file being replaced.
      # Use the same uploader and access control parameters as the oldest file being replaced.
      oldest = safe.sort_by{|f| f.id}.first
      @data_file.created_by = oldest.created_by
      @data_file.access = oldest.access
      @data_file.access_to_all_institutional_users = oldest.access_to_all_institutional_users
      @data_file.access_to_user_groups = oldest.access_to_user_groups
      @data_file.access_groups = oldest.access_groups
      @data_file.add_message(:info, "The file has inherited ownership and access control metadata from #{oldest.filename}")

      @data_file.file_processing_description = replaced_descriptions.join(', ') if @data_file.file_processing_description.blank?
      @data_file.parent_ids = @data_file.parent_ids + replaced_parents - replaced_children
      @data_file.child_ids = @data_file.child_ids + replaced_children
      @data_file.save!

      users_with_replaced_files_in_cart = []
      safe.each do |df|
        users_with_replaced_files_in_cart += df.users
        File.delete df.path
        df.destroy
      end

      # if we renamed the file, but then deleted the file it clashed with, rename it back
      if replaced_filenames.include?(@original_filename) and (@data_file.filename != @original_filename)
        @data_file.rename_to(File.join(@files_root, @original_filename), @original_filename)
      end

      # replace old file(s) with new one in carts
      users_with_replaced_files_in_cart.uniq!
      users_with_replaced_files_in_cart.each do |user|
        user.cart_items << @data_file
      end
      @data_file.add_message(:info, "Carts have been updated.") unless users_with_replaced_files_in_cart.empty?
    end
  end
end
