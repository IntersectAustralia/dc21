class CustomDownloadBuilder

  def self.zip_for_files_with_ids(ids, &block)
    file_paths = DataFile.find(ids).collect(&:path)

    zip_file = Tempfile.new("temp_file")
    ZipBuilder.build_zip(zip_file, file_paths)

    block.yield(zip_file)
    zip_file.close
    zip_file.unlink
  end

  def self.subsetted_zip_for_files(files, date_range, from_date_string, to_date_string, &block)
    temp_dir = Dir.mktmpdir
    paths = []
    files.each do |file|
      if file.has_data_in_range?(date_range.from_date, date_range.to_date)
        paths << Toa5Subsetter.extract_matching_rows_to(file, temp_dir, from_date_string, to_date_string)
      end
    end

    return false if paths.empty?

    zip_file = Tempfile.new("temp_file")
    ZipBuilder.build_zip(zip_file, paths)

    block.yield(zip_file)

    zip_file.close
    zip_file.unlink

    true
  end
end