require 'spec_helper'

describe ExifParser do

  let(:image_with_a_metadata) do
    path = Rails.root.join('spec/samples', 'Image_file_with_metadata.jpg')
    Factory.build(:data_file, :path => path, :filename => 'Image_file_with_metadata.jpg')
  end

  let(:image_with_a_blank_metadata_value) do
    path = Rails.root.join('spec/samples', 'Image_with_a_blank_metadata_value.JPG')
    Factory.build(:data_file, :path => path, :filename => 'Image_with_a_blank_metadata_value.JPG')
  end

  let(:toa5_dat) do
    path = Rails.root.join('spec/samples', 'toa5.dat')
    Factory(:data_file, :path => path, :filename => 'toa5.dat')
  end

  describe "valid file" do
    it "should extract the metadata from the file" do
      data_file = image_with_a_metadata
      data_file.path = data_file.path.to_s
      ExifParser.extract_metadata(data_file)
      data_file.start_time.to_s.should eq("2014-03-10 11:50:40 +1100")
      data_file.end_time.to_s.should eq("2014-03-10 11:50:40 +1100")
      # reload to make sure it survives being persisted
      data_file.reload
      # stick in a hash for easier assertions
      metadata = Hash[*data_file.metadata_items.collect{|mi| [mi.key, mi.value]}.flatten]
      metadata.size.should eq(47)

      metadata["gps_altitude"].should eq("10/1")
      metadata["gps_longitude"].should eq("177.473145")
      metadata["gps_longitude_ref"].should eq("E")
      metadata["gps_latitude"].should eq("-18.135411666666666")
      metadata["gps_latitude_ref"].should eq("S")
      metadata["gps_version_id"].should eq("\x02\x02")
      metadata["subject_distance_range"].should eq("0")
      metadata["sharpness"].should eq("0")
      metadata["saturation"].should eq("0")
      metadata["contrast"].should eq("0")
      metadata["gain_control"].should eq("0")
      metadata["scene_capture_type"].should eq("0")
      metadata["focal_length_in_35mm_film"].should eq("14")
      metadata["digital_zoom_ratio"].should eq("1/1")
      metadata["white_balance"].should eq("0")
      metadata["exposure_mode"].should eq("0")
      metadata["custom_rendered"].should eq("0")
      metadata["sensing_method"].should eq("2")
      metadata["focal_plane_resolution_unit"].should eq("4")
      metadata["focal_plane_y_resolution"].should eq("2096039/8192")
      metadata["focal_plane_x_resolution"].should eq("2096039/8192")
      metadata["subsec_time_digitized"].should eq("70")
      metadata["subsec_time_orginal"].should eq("70")
      metadata["focal_length"].should eq("19/2")
      metadata["flash"].should eq("16")
      metadata["light_source"].should eq("0")
      metadata["metering_mode"].should eq("5")
      metadata["max_aperture_value"].should eq("9/2")
      metadata["exposure_bias_value"].should eq("0/1")
      metadata["aperture_value"].should eq("4.8")
      metadata["shutter_speed_value"].should eq("1/999")
      metadata["date_time_digitized"].should eq("2014-02-17 22:37:19.000000")
      metadata["date_time_original"].should eq("2014-02-17 22:37:19.000000")
      metadata["iso_speed_ratings"].should eq("100")
      metadata["exposure_program"].should eq("3")
      metadata["f_number"].should eq("24/5")
      metadata["exposure_time"].should eq("1/1000")
      metadata["date_time"].should eq("2014-03-10 00:50:40.000000")
      metadata["software"].should eq("Adobe Photoshop Lightroom 5.0 (Macintosh)")
      metadata["resolution_unit"].should eq("2")
      metadata["y_resolution"].should eq("240/1")
      metadata["x_resolution"].should eq("240/1")
      metadata["model"].should eq("NIKON D7100")
      metadata["make"].should eq("NIKON CORPORATION")
      metadata["bits"].should eq("8")
      metadata["height"].should eq("3796")
      metadata["width"].should eq("5694")
    end

    it "should ignore metadata that has blank values" do
      data_file = image_with_a_blank_metadata_value
      data_file.path = data_file.path.to_s
      ExifParser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload

      metadata = Hash[*data_file.metadata_items.collect{|mi| [mi.key, mi.value]}.flatten]
      metadata.size.should eq(41)

      metadata.should_not have_key("copyright")
    end
  end

  describe "invalid file" do
    it "should do nothing if file is not an exif compatible file" do
      data_file = toa5_dat
      data_file.path = data_file.path.to_s
      result = ExifParser.extract_metadata(data_file)
      result.should be_nil
    end
  end

end
