require 'csv'

class Toa5Parser
  def self.extract_metadata(data_file)
    data_file_attrs, metadata_items_as_hash, column_details_attrs = read_metadata(data_file)

    data_file.update_attributes! data_file_attrs

    column_details_attrs.each do |attrs|
      data_file.column_details.create!(attrs)
    end

    metadata_items_as_hash.each do |k, v|
      data_file.add_metadata_item(k, v)
    end
  end

  def self.assign_time_metadata_returning_other_metadata(data_file)
    # intentionally doesn't save data_file
    data_file_attrs, metadata_items_as_hash, _ = read_metadata(data_file)

    data_file.assign_attributes data_file_attrs

    metadata_items_as_hash
  end

  private

  def self.read_metadata(data_file)
    # returns data_file_attrs, "metadata_item" attrs as a hash, array of column details attrs

    file = File.new(data_file.path)

    interesting_lines = extract_interesting_lines(file)
    header_line = interesting_lines[:line_1]
    column_names_line = interesting_lines[:line_2]
    units_line = interesting_lines[:line_3]
    column_types_line = interesting_lines[:line_4]
    data_line_1 = interesting_lines[:line_5]
    data_line_2 = interesting_lines[:line_6]
    last_line = interesting_lines[:last_line]

    delimiter = Toa5Utilities.detect_delimiter(header_line)

    column_details_attrs = extract_column_details_attrs(column_names_line, units_line, column_types_line, delimiter)
    data_file_attrs = extract_data_file_attrs(data_line_1, data_line_2, last_line, delimiter)
    metadata_items_as_hash = extract_header_line_info(header_line, delimiter)

    return data_file_attrs, metadata_items_as_hash, column_details_attrs
  end

  def self.extract_data_file_attrs(data_line_1, data_line_2, last_line, delimiter)
    attrs = {}

    if data_line_1
      start_time = Toa5Utilities.extract_time_from_data_line(data_line_1, delimiter)
      attrs[:start_time] = start_time if start_time
      attrs[:interval] = Toa5Utilities.extract_time_from_data_line(data_line_2, delimiter) - start_time if (data_line_2 && start_time)
    end
    attrs[:end_time] = Toa5Utilities.extract_time_from_data_line(last_line, delimiter) if last_line

    return attrs
  end

  def self.extract_header_line_info(header_line, delimiter)
    if header_line
      headers = Toa5Utilities.parse_line(header_line, delimiter)

      station_name = headers[1]
      model = headers[2]
      serial_number= headers[3]
      os_version = headers[4]
      dld_name = headers[5]
      dld_signature = headers[6]
      table_name = headers[7]

      metadata_item_attrs = {}
      metadata_item_attrs["datalogger_model"] = model unless model.blank?
      metadata_item_attrs["station_name"] = station_name unless station_name.blank?
      metadata_item_attrs["serial_number"] = serial_number unless serial_number.blank?
      metadata_item_attrs["os_version"] = os_version unless os_version.blank?
      metadata_item_attrs["dld_name"] = dld_name unless dld_name.blank?
      metadata_item_attrs["dld_signature"] = dld_signature unless dld_signature.blank?
      metadata_item_attrs["table_name"] = table_name unless table_name.blank?
      metadata_item_attrs
    else
      {}
    end
  end

  def self.extract_column_details_attrs(column_names_line, units_line, column_types_line, delimiter)
    if column_names_line && units_line && column_types_line
      headers = Toa5Utilities.parse_line(column_names_line, delimiter)
      units = Toa5Utilities.parse_line(units_line, delimiter)
      col_types = Toa5Utilities.parse_line(column_types_line, delimiter)
      extract_column_info(headers, units, col_types)
    else
      {}
    end
  end

  def self.extract_column_info(headers, units, col_types)
    col_info = []
    headers.each_with_index do |header, index|
      col_info << {:name => header, :unit => units[index], :data_type => col_types[index], :position => index} unless header.blank?
    end
    col_info
  end

  def self.extract_interesting_lines(file)
    lines = {}
    file.each_line.with_index(1) do |line, counter|
      lines[:line_1] = line if counter == 1
      lines[:line_2] = line if counter == 2
      lines[:line_3] = line if counter == 3
      lines[:line_4] = line if counter == 4
      lines[:line_5] = line if counter == 5
      lines[:line_6] = line if counter == 6
      lines[:last_line] = line
    end
    lines
  end

end
