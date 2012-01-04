require 'csv'

class Toa5Utilities

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

  def self.parse_line(line, delimiter)
    CSV.parse_line(line, {:col_sep => delimiter, :quote_char => '"'})
  end

  def self.detect_delimiter(header_line)
    header_line =~ /^"?TOA5"?\t/ ? "\t" : ","
  end
end