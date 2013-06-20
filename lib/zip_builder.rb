class ZipBuilder

  def self.build_simple_zip_from_files(zip_path, file_details)
    Zip::ZipFile.open(zip_path, Zip::ZipFile::CREATE) do |zipfile|
      file_details.each do |file_details|
        name = file_details[0]
        path_to_file = file_details[1]
        # Takes two arguments:
        # - The name of the file as it will appear in the archive
        # - The original file, including the path to find it
        zipfile.add(name, path_to_file)
      end
    end
  end

  def self.build_zip(zip_file, file_paths)
    Zip::ZipOutputStream.open(zip_file.path) do |zos|
      file_paths.each do |path|
        if File.directory?(path)
          dir_name = File.basename(path)
          all_files = Dir.foreach(path).reject { |f| f.starts_with?(".") }
          all_files.each do |file|
            zos.put_next_entry("#{dir_name}/#{file}")
            file = File.open(File.join(path, file), 'rb')
            write_to_zip(zos, file)
          end
        else
          # Single file processing
          zos.put_next_entry(File.basename(path))
          file = File.open(path, 'rb')
          write_to_zip(zos, file)
        end
      end
    end
  end

  def self.write_to_zip(zos, file)
    chunk_size = 1024 * 1024
    each_chunk(file, chunk_size) do |chunk|
      zos << chunk
    end
  end

  def self.each_chunk(file, chunk_size=1024)
    yield file.read(chunk_size) until file.eof?
  end
end
