require 'bagit'

class CustomDownloadBuilder

  def self.zip_for_files(data_files, &block)
    temp_dir = Dir.mktmpdir
    zip_file_path = Dir::Tmpname.make_tmpname("/tmp/download_zip", nil)
    begin
      file_details = data_files.collect { |df| [df.filename, df.path] }

      ZipBuilder.build_simple_zip_from_files(zip_file_path, file_details)
      File.chmod(00644, zip_file_path)
      block.yield(File.new(zip_file_path))
    ensure
      FileUtils.remove_entry_secure temp_dir
    end
  end


  def self.bagit_for_files_with_ids(ids, pkg, &block)
    path = "#{File.join(APP_CONFIG['files_root'], "#{pkg.external_id}_T")}"
    Dir.mkdir path

    zip_path = "#{File.join(APP_CONFIG['files_root'], "#{pkg.external_id}.tmp")}"
    zip_file = File.new(zip_path, 'a+')

    begin
      pkg.mark_as_working

      bag = BagIt::Bag.new path
      readme_path = File.join(bag.data_dir, "README.html")

      data_files = DataFile.find(ids)
      data_files.each do |data_file|
        temp_path = File.join(bag.data_dir,  data_file.filename)
        FileUtils.cp data_file.path, temp_path
        temp_path
      end

      readme_html = MetadataWriter.generate_metadata_for(data_files, pkg)
      File.open(readme_path, 'w+') { |f| f.write(readme_html) }

      bag.manifest!

      ZipBuilder.build_zip(zip_file, Dir["#{path}/*"])
      block.yield(zip_file)
    rescue Exception => e
      # Mark package then bubble exception
      @package.mark_as_failed
      raise e
    ensure
      zip_file.close
      FileUtils.rm_rf path
      FileUtils.rm zip_path
    end
  end


end
