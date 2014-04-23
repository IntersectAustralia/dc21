require 'rubygems'
require 'exifr'

class ExifParser

  def self.extract_metadata(data_file)
    begin
      exif_info = nil
      case data_file.path.downcase
        when /.jpeg\Z/
          exif_info = EXIFR::JPEG.new(data_file.path)
        when /.jpg\Z/
          exif_info = EXIFR::JPEG.new(data_file.path)
        when /.tiff\Z/
          exif_info = EXIFR::TIFF.new(data_file.path)
        when /.tif\Z/
          exif_info = EXIFR::TIFF.new(data_file.path)
      end

      if exif_info
        data_file_attrs = {}
        data_file_attrs[:start_time] = exif_info.date_time
        data_file_attrs[:end_time] = exif_info.date_time
        data_file.update_attributes! data_file_attrs
        
        exif_info.to_hash.each do |k, v|
          if v and v != "" and k.to_s != "user_comment" and k.to_s != "gps_time_stamp"
            if k.to_s == "gps_longitude"
              longitude_as_a_decimal_value = convert_sexagesimal_to_decimal(v)
              longitude_as_a_decimal_value = longitude_as_a_decimal_value * -1 if exif_info.gps_longitude_ref == "W"   # (W is -, E is +)
              data_file.add_metadata_item(k, longitude_as_a_decimal_value)
            elsif k.to_s == "gps_latitude"
              latitude_as_a_decimal_value = convert_sexagesimal_to_decimal(v)
              latitude_as_a_decimal_value = latitude_as_a_decimal_value * -1 if exif_info.gps_latitude_ref == "S"   # (S is -, N is +)
              data_file.add_metadata_item(k, latitude_as_a_decimal_value)
            elsif k.to_s == "orientation"
              data_file.add_metadata_item(k, v.to_i)
            else
              data_file.add_metadata_item(k, v)
            end
          end
        end
      end
    rescue EXIFR::MalformedImage
      return nil
    end
  end

  private
  def self.convert_sexagesimal_to_decimal(sexagesimal_value)
    return sexagesimal_value[0].to_f + (sexagesimal_value[1].to_f/60) + (sexagesimal_value[2].to_f/3600)
  end

end