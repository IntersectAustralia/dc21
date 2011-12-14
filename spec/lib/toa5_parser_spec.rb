require 'spec_helper'

describe Toa5Parser do

  let(:toa5_dat) do
    path = Rails.root.join('spec/samples', 'toa5.dat')
    Factory(:data_file, :path => path, :filename => 'toa5.dat')
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

      data_file.metadata[:datalogger_model].should eq("CR3000")
      data_file.metadata[:station_name].should eq("ROS_WS")
      data_file.metadata[:serial_number].should eq("4909")
      data_file.metadata[:os_version].should eq("CR3000.Std.11")
      data_file.metadata[:dld_name].should eq("CPU:weather_station_final.CR3")
      data_file.metadata[:dld_signature].should eq("30238")
      data_file.metadata[:table_name].should eq("Table05min")
    end

    it "should extract column header information" do
      data_file = toa5_dat
      Toa5Parser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload

      headers = data_file.metadata[:column_headers]
      headers.is_a?(Array).should be_true
      headers.length.should eq(15)
      headers[0].should eq(["TIMESTAMP", "TS", ""])
      headers[1].should eq(["RECORD", "RN", ""])
      headers[2].should eq(["PPFD_Avg", "mV", "Avg"])
      headers[14].should eq(["LWMWet_Tot", "Minutes", "Tot"])
    end

    it "should ignore blanks column header information" do
      data_file = toa5_dat_with_blanks
      Toa5Parser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload

      headers = data_file.metadata[:column_headers]
      headers.is_a?(Array).should be_true
      headers.length.should eq(4)
      headers[0].should eq(["TIMESTAMP", "TS", ""])
      headers[1].should eq(["RECORD", "RN", ""])
      headers[2].should eq(["BattV_Min", "Volts", "Min"])
      headers[3].should eq(["PTemp_C_Max", "Deg C", "Max"])
    end
  end

  describe "invalid file" do
    it "should do nothing if file doesn't conform to expected format" do
      data_file = not_really_toa5
      Toa5Parser.extract_metadata(data_file)
      data_file.start_time.should be_nil
      data_file.end_time.should be_nil
      data_file.metadata.should be_empty
    end
  end

  describe "Parse time" do
    it "should parse times that match the format used in TOA5" do
      Toa5Parser.parse_time("8/10/2011 9:55").to_s.should eq("2011-10-08 09:55:00 UTC")
      Toa5Parser.parse_time("8/10/2011 10:00").to_s.should eq("2011-10-08 10:00:00 UTC")
      Toa5Parser.parse_time("12/10/2011 1:50").to_s.should eq("2011-10-12 01:50:00 UTC")
      Toa5Parser.parse_time("13/10/2011 22:25").to_s.should eq("2011-10-13 22:25:00 UTC")
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
