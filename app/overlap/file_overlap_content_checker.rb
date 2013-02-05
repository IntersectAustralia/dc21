class FileOverlapContentChecker
  def initialize(old_file, new_file)
    @old_file = old_file
    @new_file = new_file
  end

  def content_matches
    # check if the chunk of new_file that overlaps with old_file is identical

    start_comparison_time = @old_file.start_time
    end_comparison_time = @old_file.end_time

    if @new_file.start_time == start_comparison_time && @new_file.end_time == end_comparison_time
      # no need to subset if files are identical
      FileUtils.identical?(@old_file.path, @new_file.path)
    else
      Dir.mktmpdir do |temp_dir|
        subsetted_new_file = subset_new_file(temp_dir)
        FileUtils.identical?(@old_file.path, subsetted_new_file)
      end
    end
  end

  # This has been modified from the original implementation to be faster. Rather than parsing each line to check
  # where we're up to, it just looks for a line that matches the first line from old file, and keeps grabbing
  # lines until we get to a line that matches the last line from old file. This is 10x faster than the old way
  def subset_new_file(temp_dir)
    old_file = File.open(@old_file.path)
    new_file = File.open(@new_file.path)
    outfile_name = File.join(temp_dir, @new_file.filename)
    outfile = File.open(outfile_name, 'w')

    #get first and last fine from old file
    counter = 1
    first_data_line = nil
    last_data_line = nil
    old_file.each_line do |line|
      first_data_line = line if counter == 5
      last_data_line = line unless line.blank?
      counter += 1
    end

    found_first_line = false
    found_last_line = false
    counter = 1
    # iterate over new file and copy relevant lines to a temp file
    new_file.each_line do |line|
      if counter <= 4
        outfile.puts(line)
      else
        if !found_first_line && line == first_data_line
          found_first_line = true
        end
        if found_first_line && !found_last_line
          outfile.puts(line)
        end
        if found_first_line && line == last_data_line
          found_last_line = true
        end
      end
      counter += 1
    end

    new_file.close
    old_file.close
    outfile.close
    outfile_name
  end
end
