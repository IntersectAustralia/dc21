require 'spec_helper'

describe DataFile do
  describe "Validations" do
    it { should validate_presence_of(:filename) }
    it { should validate_presence_of(:path) }
    it { should validate_presence_of(:created_by_id) }
  end

  describe "Associations" do
    it { should belong_to(:created_by) }
    it { should have_many(:column_details) }
    it { should have_many(:metadata_items) }
  end

  describe "Get file extension" do
    it "should return the correct extension" do
      Factory(:data_file, :filename => "abc.csv").extension.should eq("csv")
      Factory(:data_file, :filename => "abc.def.csv").extension.should eq("csv")
      Factory(:data_file, :filename => "abc.txt").extension.should eq("txt")
      Factory(:data_file, :filename => "abc.txt123").extension.should eq("txt123")
      Factory(:data_file, :filename => "txt123").extension.should be_nil
    end

    it "should downcase the extension" do
      Factory(:data_file, :filename => "abc.csv").extension.should eq("csv")
      Factory(:data_file, :filename => "abc.CSV").extension.should eq("csv")
      Factory(:data_file, :filename => "abc.cSV").extension.should eq("csv")
      Factory(:data_file, :filename => "abc.Csv").extension.should eq("csv")
    end
  end

  describe "File format for display" do
    it "should return 'Unknown' if no format set" do
      Factory(:data_file, :format => nil).format_for_display.should eq("Unknown")
    end

    it "should return the format if set" do
      Factory(:data_file, :format => "TOA5").format_for_display.should eq("TOA5")
    end
  end

  describe "Find files for date range" do
    before do
      @f1 = Factory(:data_file, :start_time => "2011-01-01 11:00 UTC", :end_time => "2011-02-28 11:00 UTC").id # starts before, ends after = IN
      @f2 = Factory(:data_file, :start_time => "2011-01-01 00:00 UTC", :end_time => "2011-04-30 22:59 UTC").id # starts on, ends after = IN
      @f3 = Factory(:data_file, :start_time => "2011-02-01 11:00 UTC", :end_time => "2011-03-31 22:59 UTC").id # starts on, ends after = IN
      @f4 = Factory(:data_file, :start_time => "2011-03-01 11:00 UTC", :end_time => "2011-04-30 11:00 UTC").id # starts after, ends after = OUT
      @f5 = Factory(:data_file, :start_time => "2011-01-01 11:00 UTC", :end_time => "2011-01-31 11:00 UTC").id # starts before, ends before = OUT
      @f6 = Factory(:data_file, :start_time => "2011-04-01 00:00 UTC", :end_time => "2011-04-30 11:00 UTC").id # starts before, ends on = IN
      @f8 = Factory(:data_file, :start_time => nil, :end_time => nil)
    end

    it "when searching with start date only should return all files which end on or after the given date" do
      search_result = DataFile.with_data_in_range(Date.parse("2011-03-01"), nil)
      search_result.size.should eq(4)
      search_result.collect(&:id).sort.should eq([@f2, @f3, @f4, @f6])

      search_result = DataFile.with_data_in_range(Date.parse("2011-04-30"), nil)
      search_result.size.should eq(3)
      search_result.collect(&:id).sort.should eq([@f2, @f4, @f6])

      search_result = DataFile.with_data_in_range(Date.parse("2011-05-01"), nil)
      search_result.size.should eq(0)
    end

    it "when searching with end date only should return all files that start on or before the given date" do
      search_result = DataFile.with_data_in_range(nil, Date.parse("2011-03-01"))
      search_result.size.should eq(5)
      search_result.collect(&:id).sort.should eq([@f1, @f2, @f3, @f4, @f5])

      search_result = DataFile.with_data_in_range(nil, Date.parse("2011-02-28"))
      search_result.size.should eq(4)
      search_result.collect(&:id).sort.should eq([@f1, @f2, @f3, @f5])

      search_result = DataFile.with_data_in_range(nil, Date.parse("2011-01-01"))
      search_result.size.should eq(3)
      search_result.collect(&:id).sort.should eq([@f1, @f2, @f5])

      search_result = DataFile.with_data_in_range(nil, Date.parse("2010-12-31"))
      search_result.size.should eq(0)
    end

    it "when searching with both dates should only return files that have data falling in the range" do
      search_result = DataFile.with_data_in_range(Date.parse("2010-01-01"), Date.parse("2010-12-31"))
      search_result.size.should eq(0)

      search_result = DataFile.with_data_in_range(Date.parse("2010-01-01"), Date.parse("2011-01-01"))
      search_result.size.should eq(3)
      search_result.collect(&:id).sort.should eq([@f1, @f2, @f5])

      search_result = DataFile.with_data_in_range(Date.parse("2010-01-01"), Date.parse("2011-02-01"))
      search_result.size.should eq(4)
      search_result.collect(&:id).sort.should eq([@f1, @f2, @f3, @f5])

      #single day
      search_result = DataFile.with_data_in_range(Date.parse("2011-02-01"), Date.parse("2011-02-01"))
      search_result.size.should eq(3)
      search_result.collect(&:id).sort.should eq([@f1, @f2, @f3])

      search_result = DataFile.with_data_in_range(Date.parse("2011-02-15"), Date.parse("2011-03-15"))
      search_result.size.should eq(4)
      search_result.collect(&:id).sort.should eq([@f1, @f2, @f3, @f4])

      search_result = DataFile.with_data_in_range(Date.parse("2011-04-01"), Date.parse("2011-12-12"))
      search_result.size.should eq(3)
      search_result.collect(&:id).sort.should eq([@f2, @f4, @f6])

      search_result = DataFile.with_data_in_range(Date.parse("2011-04-30"), Date.parse("2011-12-12"))
      search_result.size.should eq(3)
      search_result.collect(&:id).sort.should eq([@f2, @f4, @f6])

      search_result = DataFile.with_data_in_range(Date.parse("2011-05-01"), Date.parse("2011-12-12"))
      search_result.size.should eq(0)
    end
  end

  describe "Find files for station name" do
    it "should find only files with the matching metadata item" do
      f1 = Factory(:data_file)
      f2 = Factory(:data_file)
      f3 = Factory(:data_file)
      f4 = Factory(:data_file)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "ABC", :data_file => f1)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "DEF", :data_file => f2)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "GHI", :data_file => f3)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "ABC", :data_file => f4)
      Factory(:metadata_item, :key => "other key", :value => "ABC", :data_file => f3)
      DataFile.with_station_name_in(["ABC"]).collect(&:id).sort.should eq([f1.id, f4.id])
      DataFile.with_station_name_in(["ABC", "DEF"]).collect(&:id).sort.should eq([f1.id, f2.id, f4.id])
      DataFile.with_station_name_in(["ABC", "ASDF"]).collect(&:id).sort.should eq([f1.id, f4.id])
      DataFile.with_station_name_in(["ASDF"]).collect(&:id).sort.should eq([])
    end
  end

  describe "Getting set of facilities for searching" do

    it "should exclude mapped facilities that don't have any records, and should include unmapped facilities" do
      df1 = Factory(:data_file)
      df1.metadata_items.create!(:key => "station_name", :value => "code2")

      df1 = Factory(:data_file)
      df1.metadata_items.create!(:key => "station_name", :value => "ROS_WS")

      df1 = Factory(:data_file)
      df1.metadata_items.create!(:key => "station_name", :value => "code2")

      Factory(:facility, :name => "Name1", :code => "code1")
      Factory(:facility, :name => "Name2", :code => "code2")
      searchables = DataFile.searchable_facilities
      searchables.size.should eq(2)
      searchables[0][0].should eq("code2")
      searchables[0][1].should eq("Name2")
      searchables[1][0].should eq("ROS_WS")
      searchables[1][1].should eq("ROS_WS")
    end
  end
end
