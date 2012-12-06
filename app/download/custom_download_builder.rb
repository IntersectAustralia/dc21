class CustomDownloadBuilder

  def self.zip_for_files_with_ids(ids, &block)
    temp_dir = Dir.mktmpdir
    readme_path = File.join(temp_dir, "README.html")

    data_files = DataFile.find(ids)

    file_paths = data_files.collect do |data_file|
      temp_path = File.join(temp_dir, data_file.filename)
      FileUtils.cp data_file.path, temp_path
      temp_path
    end

    readme_html = MetadataWriter.generate_metadata_for(data_files)
    File.open(readme_path, 'w+') { |f| f.write(readme_html) }
    file_paths << readme_path

    zip_file = Tempfile.new("download_zip")
    ZipBuilder.build_zip(zip_file, file_paths)

    block.yield(zip_file)
    zip_file.close
    zip_file.unlink
  end

end
