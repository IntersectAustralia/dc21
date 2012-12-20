Then /^I should receive a zip file matching "([^"]*)"$/ do |directory|
  #saves the latest response, unzips it, then compares with a pre-defined directory of files that match what you expect the zip to contain
  compare_zip_to_expected_files(page.source, directory)
end

def compare_zip_to_expected_files(response_source, directory)
  downloaded_files = save_response_as_zip_and_unpack(response_source)
  expected_files = Dir.glob(File.join(Rails.root, directory, "/**/*"))

  expected_files.each do |path_to_expected_file|
    next if File.directory?(path_to_expected_file)
    downloaded_file_path = downloaded_files[File.basename(path_to_expected_file)]
    if downloaded_file_path.nil?
      raise "Expected downloaded zip to include file #{File.basename(path_to_expected_file)} but did not find it. Found #{downloaded_files.keys}."
    else
      downloaded_file_path.should be_same_file_as(path_to_expected_file)
    end
  end
end

def save_response_as_zip_and_unpack(response_source)
  tempfile = Tempfile.new(["temp_file", ".zip"])
  tempfile.close
  zip = File.open(tempfile.path, "wb")
  zip.write(response_source)
  zip.close
  temp_dir = Dir.mktmpdir

  downloaded_files = {}
  Zip::ZipFile.foreach(zip.path) do |file|
    if (file.name.include?("/"))
      dir = File.join(temp_dir, file.name.split("/")[0])
      file_name = file.name.split("/")[1]
      if file_name.starts_with?("name-")
        file_name = "name-1.txt"
      end
      unless (File.directory?(dir))
        Dir.mkdir(dir)
      end
    else
      dir = temp_dir
      file_name = file.name
    end
    path = File.join(dir, file_name)
    file.extract(path)
    downloaded_files[file_name] = path
  end

  downloaded_files
end

