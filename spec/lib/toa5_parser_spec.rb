require 'spec_helper'

describe Toa5Parser do

  let(:toa5_dat) do
    path = Rails.root.join('spec/samples', 'toa5.dat')
    Factory(:data_file, :path => path, :filename => 'toa5.dat')
  end

  let(:toa5_quoted_dat) do
    path = Rails.root.join('spec/samples', 'toa5_quoted.dat')
    Factory(:data_file, :path => path, :filename => 'toa5_quoted.dat')
  end

  let(:not_really_toa5) do
    path = Rails.root.join('spec/samples', 'not-really-toa5.dat')
    Factory(:data_file, :path => path, :filename => 'not-really-toa5.dat')
  end

  let(:toa5_dat_with_blanks) do
    path = Rails.root.join('spec/samples', 'toa5_with_blanks.dat')
    Factory(:data_file, :path => path, :filename => 'toa5_with_blanks.dat')
  end

  describe "valid file" do
    it "should extract the start date from the file" do
      data_file = toa5_dat
      Toa5Parser.extract_metadata(data_file)
      data_file.start_time.should eq("6/10/2011 0:40")
      data_file.end_time.should eq("3/11/2011 11:55")
    end

    it "should extract datalogger info from first line" do
      data_file = toa5_dat
      Toa5Parser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload
      # stick in a hash for easier assertions
      metadata = Hash[*data_file.metadata_items.collect{|mi| [mi.key, mi.value]}.flatten]
      metadata.size.should eq(7)

      metadata["datalogger_model"].should eq("CR3000")
      metadata["station_name"].should eq("ROS_WS")
      metadata["serial_number"].should eq("4909")
      metadata["os_version"].should eq("CR3000.Std.11")
      metadata["dld_name"].should eq("CPU:weather_station_final.CR3")
      metadata["dld_signature"].should eq("30238")
      metadata["table_name"].should eq("Table05min")
    end

    it "should extract column header information" do
      data_file = toa5_dat
      Toa5Parser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload

      headers = data_file.column_details
      headers.length.should eq(15)
      headers[0].name.should eq("TIMESTAMP")
      headers[0].unit.should eq("TS")
      headers[0].data_type.should be_nil
      headers[0].position.should eq(0)

      headers[1].name.should eq("RECORD")
      headers[1].unit.should eq("RN")
      headers[1].data_type.should be_nil
      headers[1].position.should eq(1)

      headers[2].name.should eq("PPFD_Avg")
      headers[2].unit.should eq("mV")
      headers[2].data_type.should eq("Avg")
      headers[2].position.should eq(2)

      headers[14].name.should eq("LWMWet_Tot")
      headers[14].unit.should eq("Minutes")
      headers[14].data_type.should eq("Tot")
      headers[14].position.should eq(14)
    end

    it "should ignore blanks column header information" do
      data_file = toa5_dat_with_blanks
      Toa5Parser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload

      headers = data_file.column_details
      headers.length.should eq(4)
      headers[0].name.should eq("TIMESTAMP")
      headers[0].unit.should eq("TS")
      headers[0].data_type.should be_nil
      headers[0].position.should eq(0)

      headers[1].name.should eq("RECORD")
      headers[1].unit.should eq("RN")
      headers[1].data_type.should be_nil
      headers[1].position.should eq(1)

      headers[2].name.should eq("BattV_Min")
      headers[2].unit.should eq("Volts")
      headers[2].data_type.should eq("Min")
      headers[2].position.should eq(2)

      headers[3].name.should eq("PTemp_C_Max")
      headers[3].unit.should eq("Deg C")
      headers[3].data_type.should eq("Max")
      headers[3].position.should eq(3)
    end
  end

  describe "valid file - older style with quotes" do
    it "should extract the start date from the file" do
      data_file = toa5_quoted_dat
      Toa5Parser.extract_metadata(data_file)
      data_file.start_time.should eq("2011-08-11 09:30:00")
      data_file.end_time.should eq("2011-11-02 13:00:00")
    end

    it "should extract datalogger info from first line" do
      data_file = toa5_quoted_dat
      Toa5Parser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload
      # stick in a hash for easier assertions
      metadata = Hash[*data_file.metadata_items.collect{|mi| [mi.key, mi.value]}.flatten]
      metadata.size.should eq(7)

      metadata["datalogger_model"].should eq("CR1000")
      metadata["station_name"].should eq("WTC11")
      metadata["serial_number"].should eq("33275")
      metadata["os_version"].should eq("CR1000.Std.19")
      metadata["dld_name"].should eq("CPU:WTCsensors_Ch11.CR1")
      metadata["dld_signature"].should eq("30773")
      metadata["table_name"].should eq("Table1")
    end

    it "should extract column header information" do
      data_file = toa5_quoted_dat
      Toa5Parser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload

      headers = data_file.column_details
      headers.length.should eq(15)
      headers[0].name.should eq("TIMESTAMP")
      headers[0].unit.should eq("TS")
      headers[0].data_type.should eq("")
      headers[0].position.should eq(0)

      headers[5].name.should eq("SoilTempProbe_Avg(1)")
      headers[5].unit.should eq("Deg C")
      headers[5].data_type.should eq("Avg")
      headers[5].position.should eq(5)
    end

  end

  describe "invalid file" do
    it "should do nothing if file doesn't conform to expected format" do
      data_file = not_really_toa5
      Toa5Parser.extract_metadata(data_file)
      data_file.start_time.should be_nil
      #data_file.end_time.should be_nil
      data_file.metadata_items.should be_empty
    end
  end

  describe "Parse time" do
    it "should parse times that match the format used in TOA5" do
      Toa5Parser.parse_time("8/10/2011 9:55").to_s.should eq("2011-10-08 09:55:00 UTC")
      Toa5Parser.parse_time("8/10/2011 10:00").to_s.should eq("2011-10-08 10:00:00 UTC")
      Toa5Parser.parse_time("12/10/2011 1:50").to_s.should eq("2011-10-12 01:50:00 UTC")
      Toa5Parser.parse_time("13/10/2011 22:25").to_s.should eq("2011-10-13 22:25:00 UTC")
      Toa5Parser.parse_time("2011-08-11 09:30:00").to_s.should eq("2011-08-11 09:30:00 UTC")
    end

    #it "should reject others" do
    #  Toa5Parser.parse_time("8/10/2011 9:55 AM")
    #  Toa5Parser.parse_time("8/10/11 9:55")
    #  Toa5Parser.parse_time("8/13/11 9:55")
    #  Toa5Parser.parse_time("8/13/11")
    #  Toa5Parser.parse_time("Junk")
    #end
  end
end
