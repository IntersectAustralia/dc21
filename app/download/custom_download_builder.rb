class CustomDownloadBuilder

  def self.zip_for_files_with_ids(ids, &block)
    data_files = DataFile.find(ids)
    file_paths = data_files.collect(&:path)
    file_paths << generate_metadata_for(data_files)

    zip_file = Tempfile.new("temp_file")
    ZipBuilder.build_zip(zip_file, file_paths)

    block.yield(zip_file)
    zip_file.close
    zip_file.unlink
  end

  def self.generate_metadata_for(data_files)
    temp_dir = Dir.mktmpdir
    metadata_dir = File.join(temp_dir, "metadata")
    Dir.mkdir(metadata_dir, 0700)
    m_w = MetadataWriter.new(data_files, metadata_dir)
    m_w.generate_metadata
    metadata_dir
  end
end
