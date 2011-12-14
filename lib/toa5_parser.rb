class Toa5Parser
  def self.extract_metadata(data_file)
    file = File.open(data_file.path)

    interesting_lines = extract_interesting_lines(file)

    data_file.start_time = extract_time_from_data_line(interesting_lines[:line_5]) if interesting_lines[:line_5]
    data_file.end_time = extract_time_from_data_line(interesting_lines[:last_line]) if interesting_lines[:last_line]

    extract_header_line_info(data_file, interesting_lines[:line_1]) if interesting_lines[:line_1]

    if interesting_lines[:line_2] && interesting_lines[:line_3] && interesting_lines[:line_4]
      headers = interesting_lines[:line_2].gsub("\n", "").split("\t")
      units = interesting_lines[:line_3].gsub("\n", "").split("\t")
      col_types = interesting_lines[:line_4].gsub("\n", "").split("\t")
      data_file.add_metadata_item(:column_headers, extract_column_info(headers, units, col_types))
    end
    data_file.save!
  end

  def self.extract_header_line_info(data_file, header_line)
    headers = header_line.split("\t")
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

  def self.extract_column_info(headers, units, col_types)
    col_info = []
    headers.each_with_index do |header, index|
      col_info << [header, units[index], col_types[index]] unless header.blank?
    end
    col_info
  end

  def self.extract_time_from_data_line(line)
    begin
      details = line.split("\t")
      time_string = details.first
      parse_time(time_string)
    rescue
      ::Rails.logger.info("Error parsing date from TOA5 file: #{$!} (#{time_string}")
      nil
    end
  end

  def self.parse_time(time_string)
    # Time.parse is too forgiving, so we use DateTime.strptime instead
    DateTime.strptime(time_string, "%e/%m/%Y %R").to_time
  end

  def self.extract_interesting_lines(file)
    counter = 1
    lines = {}
    file.each_line do |line|
      lines[:line_1] = line if counter == 1
      lines[:line_2] = line if counter == 2
      lines[:line_3] = line if counter == 3
      lines[:line_4] = line if counter == 4
      lines[:line_5] = line if counter == 5
      lines[:last_line] = line
      counter += 1
    end
    lines
  end

end
