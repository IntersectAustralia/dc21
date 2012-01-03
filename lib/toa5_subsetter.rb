class Toa5Subsetter
  def self.extract_matching_rows_to(data_file, temp_dir, from_date_string, to_date_string)
    # convert the dates to appropriate times in UTC since we store the times from the files in UTC
    from_time = from_date_string.blank? ? nil : Time.parse("#{from_date_string} 00:00:00 UTC")
    to_time = to_date_string.blank? ? nil : (Time.parse("#{to_date_string} 00:00:00 UTC") + 1.day) #add one day to get midnight the following day

    file = File.open(data_file.path)

    outfile_name = File.join(temp_dir, data_file.filename)
    outfile = File.open(outfile_name, 'w')

    counter = 1
    delimiter = "\t"
    file.each_line do |line|
      if counter == 1
        delimiter = Toa5Utilities.detect_delimiter(line)
      end
      if counter <= 4
        outfile.puts(line)
      else
        outfile.puts(line) if data_line_in_range?(line, from_time, to_time, delimiter)
      end

      counter += 1
    end

    file.close
    outfile.close
  end

  def self.data_line_in_range?(line, from_time, to_time, delimiter)
    time = Toa5Utilities.extract_time_from_data_line(line, delimiter)
    if (from_time && to_time)
      time >= from_time && time < to_time
    elsif from_time
      time >= from_time
    else
      time < to_time
    end
  end

end