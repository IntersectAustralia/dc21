class ZipBuilder
  def self.build_zip(zip_file, file_paths)
    Zip::ZipOutputStream.open(zip_file.path) do |zos|
      file_paths.each do |path|
        zos.put_next_entry(File.basename(path))
        zos << File.open(path, 'rb') { |file| file.read }
      end
    end
  end
end