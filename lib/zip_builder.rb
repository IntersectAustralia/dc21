class ZipBuilder
  def self.build_zip(zip_file, file_paths)
    Zip::ZipOutputStream.open(zip_file.path) do |zos|
      file_paths.each do |path|
        if File.directory?(path)
          dir_name = File.basename(path)
          all_files = Dir.foreach(path).reject { |f| f.starts_with?(".") } 
          all_files.each do |file|
            zos.put_next_entry("#{dir_name}/#{file}")
            zos << File.open(File.join(path,file), 'rb') { |file| file.read }
          end
        else
          zos.put_next_entry(File.basename(path))
          zos << File.open(path, 'rb') { |file| file.read }
        end
      end
    end
  end
end
