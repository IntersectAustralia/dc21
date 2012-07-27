class CustomDownloadBuilder

  def self.zip_for_files_with_ids(ids, &block)
    data_files = DataFile.find(ids)
    generate_metadata_for(data_files)
    file_paths = data_files.collect(&:path)

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
        if file.format == FileTypeDeterminer::TOA5
          paths << Toa5Subsetter.extract_matching_rows_to(file, temp_dir, from_date_string, to_date_string)
        else
          paths << file.path
        end
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

  def self.generate_metadata_for(data_files)
    m_w = MetadataWriter.new(data_files, Dir.new("/tmp"))
    m_w.generate_metadata
  end
end
