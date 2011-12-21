require 'csv'

class Toa5Parser
  def self.extract_metadata(data_file)
    file = File.open(data_file.path)

    interesting_lines = extract_interesting_lines(file)
    header_line = interesting_lines[:line_1]

    # do nothing if there's not even a header line
    return unless header_line

    # do our best to detect if its tab or comma delimited
    if header_line =~ /^"?TOA5"?\t/
      delimiter = "\t"
    else
      delimiter = ","
    end

    column_names_line = interesting_lines[:line_2]
    units_line = interesting_lines[:line_3]
    column_types_line = interesting_lines[:line_4]

    data_line_1 = interesting_lines[:line_5]
    data_line_2 = interesting_lines[:line_6]
    last_line = interesting_lines[:last_line]

    if data_line_1
      start_time = extract_time_from_data_line(data_line_1, delimiter)
      data_file.start_time = start_time
      data_file.interval = extract_time_from_data_line(data_line_2, delimiter) - start_time if (data_line_2 && start_time)
    end
    data_file.end_time = extract_time_from_data_line(last_line, delimiter) if last_line

    data_file.save!

    extract_header_line_info(data_file, header_line, delimiter) if header_line

    if column_names_line && units_line && column_types_line
      headers = parse_line(column_names_line, delimiter)
      units = parse_line(units_line, delimiter)
      col_types = parse_line(column_types_line, delimiter)
      extract_column_info(headers, units, col_types, data_file)
    end
  end

  def self.parse_line(line, delimiter)
    CSV.parse_line(line, {:col_sep => delimiter, :quote_char => '"'})
  end

  def self.extract_header_line_info(data_file, header_line, delimiter)
    headers = parse_line(header_line, delimiter)

    station_name = headers[1]
    model = headers[2]
    serial_number= headers[3]
    os_version = headers[4]
    dld_name = headers[5]
    dld_signature = headers[6]
    table_name = headers[7]

    data_file.add_metadata_item("datalogger_model", model) unless model.blank?
    data_file.add_metadata_item("station_name", station_name) unless station_name.blank?
    data_file.add_metadata_item("serial_number", serial_number) unless serial_number.blank?
    data_file.add_metadata_item("os_version", os_version) unless os_version.blank?
    data_file.add_metadata_item("dld_name", dld_name) unless dld_name.blank?
    data_file.add_metadata_item("dld_signature", dld_signature) unless dld_signature.blank?
    data_file.add_metadata_item("table_name", table_name) unless table_name.blank?
  end

  def self.extract_column_info(headers, units, col_types, data_file)
    col_info = []
    headers.each_with_index do |header, index|
      col_info << {:name => header, :unit => units[index], :data_type => col_types[index], :position => index} unless header.blank?
    end
    col_info.each do |column_attributes|
      data_file.column_details.create!(column_attributes)
    end
  end

  def self.extract_time_from_data_line(line, delimiter)
    begin
      details = parse_line(line, delimiter)
      time_string = details.first
      parse_time(time_string)
    rescue
      ::Rails.logger.info("Error parsing date from TOA5 file: #{$!} #{time_string}")
      nil
    end
  end

  def self.parse_time(time_string)
    # Time.parse is very forgiving, which could create unexpected results, but since we've encountered files with
    # different date formats, its our best bet for maximum compatibility
    Time.parse(time_string + " UTC")
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
      lines[:line_6] = line if counter == 6
      lines[:last_line] = line
      counter += 1
    end
    lines
  end

end
