class Toa5Parser
  def self.extract_metadata(data_file)
    file = File.open(data_file.path)

    interesting_lines = extract_interesting_lines(file)

    if interesting_lines[:line_5]
      data_file.start_time = extract_time_from_data_line(interesting_lines[:line_5])
    end

    if interesting_lines[:last_line]
      data_file.end_time = extract_time_from_data_line(interesting_lines[:last_line])
    end

    if interesting_lines[:line_1]
      headers = interesting_lines[:line_1].split("\t")
      station_name = headers[1]
      model = headers[2]
      serial_number= headers[3]
      os_version = headers[4]
      dld_name = headers[5]
      dld_signature = headers[6]
      table_name = headers[7]

      data_file.add_metadata_item(:datalogger_model, model) unless model.blank?
      data_file.add_metadata_item(:station_name, station_name) unless station_name.blank?
      data_file.add_metadata_item(:serial_number, serial_number) unless serial_number.blank?
      data_file.add_metadata_item(:os_version, os_version) unless os_version.blank?
      data_file.add_metadata_item(:dld_name, dld_name) unless dld_name.blank?
      data_file.add_metadata_item(:dld_signature, dld_signature) unless dld_signature.blank?
      data_file.add_metadata_item(:table_name, table_name) unless table_name.blank?
    end
    data_file.save!
  end


  def self.extract_time_from_data_line(line)
    details = line.split("\t")
    time_string = details.first + " UTC" #force to consider it UTC as we don't know the timezone
    Time.parse(time_string)
  end

  def self.extract_interesting_lines(file)
    counter = 1
    lines = {}
    file.each_line do |line|
      lines[:line_1] = line if counter == 1
      lines[:line_5] = line if counter == 5
      lines[:last_line] = line
      counter += 1
    end
    lines
  end

end
