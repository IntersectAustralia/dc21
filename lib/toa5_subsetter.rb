class Toa5Subsetter
  def self.extract_matching_rows_to(data_file, temp_dir, from_time_val, to_time_val, overlap = false)

    file = File.open(data_file.path)

    if overlap
      from_time = from_time_val
      to_time = to_time_val
    else
      # convert the dates to appropriate times in UTC since we store the times from the files in UTC
      from_time = from_time_val.blank? ? nil : Time.parse("#{from_time_val} 00:00:00 UTC")
      to_time = to_time_val.blank? ? nil : (Time.parse("#{to_time_val} 00:00:00 UTC") + 1.day - 1.second) #add one day to get midnight the following day
    end

    outfile_name = File.join(temp_dir, data_file.filename)
    outfile = File.open(outfile_name, 'w')

    ::Rails.logger.info "Subsetting #{data_file.path} to #{outfile_name} with range from:#{from_time} to:#{to_time}"\
    
    counter = 1
    delimiter = "\t"
    file.each_line do |line|
      if counter == 1
        delimiter = Toa5Utilities.detect_delimiter(line)
      end
      if counter <= 4
        outfile.puts(line)
      else
        if data_line_in_range?(line, from_time, to_time, delimiter)
          #if overlap
          #  line.squish!
          #  line << "\n"
          #end
          outfile.puts(line)

        end
      end

      counter += 1
    end

    file.close
    outfile.close
    outfile_name
  end

  def self.data_line_in_range?(line, from_time, to_time, delimiter)
    time = Toa5Utilities.extract_time_from_data_line(line, delimiter)
    return false if time.nil?
    if (from_time && to_time)
      time >= from_time && time <= to_time
    elsif from_time
      time >= from_time
    else
      time <= to_time
    end
  end

end