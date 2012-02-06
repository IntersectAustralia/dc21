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
      @f1 = Factory(:data_file, :start_time => "2011-01-01 11:00 UTC", :end_time => "2011-02-28 11:00 UTC", :format => "TOA5").id # jan1 to feb28
      @f2 = Factory(:data_file, :start_time => "2011-01-01 00:00 UTC", :end_time => "2011-04-30 22:59 UTC", :format => "TOA5").id # jan1 to apr30
      @f3 = Factory(:data_file, :start_time => "2011-02-01 11:00 UTC", :end_time => "2011-03-31 22:59 UTC", :format => "TOA5").id # feb1 to mar31
      @f4 = Factory(:data_file, :start_time => "2011-03-01 11:00 UTC", :end_time => "2011-04-30 11:00 UTC", :format => "TOA5").id # mar1 to apr30
      @f5 = Factory(:data_file, :start_time => "2011-01-01 11:00 UTC", :end_time => "2011-01-31 11:00 UTC", :format => "TOA5").id # jan1 to jan31
      @f6 = Factory(:data_file, :start_time => "2011-04-01 00:00 UTC", :end_time => "2011-04-30 11:00 UTC", :format => "TOA5").id # apr1 to apr30
      @f8 = Factory(:data_file, :start_time => nil, :end_time => nil, :format => nil)
    end

    describe "has data in range method should correctly identify if data falls in range" do
      it "should work with start date only" do
        DataFile.find(@f1).has_data_in_range?(Date.parse("2011-03-01"), nil).should be_false
        DataFile.find(@f2).has_data_in_range?(Date.parse("2011-03-01"), nil).should be_true
        DataFile.find(@f3).has_data_in_range?(Date.parse("2011-03-01"), nil).should be_true
        DataFile.find(@f4).has_data_in_range?(Date.parse("2011-03-01"), nil).should be_true
        DataFile.find(@f5).has_data_in_range?(Date.parse("2011-03-01"), nil).should be_false
        DataFile.find(@f6).has_data_in_range?(Date.parse("2011-03-01"), nil).should be_true
        DataFile.find(@f8).has_data_in_range?(Date.parse("2011-03-01"), nil).should be_false
      end
      it "should work with end date only" do
        DataFile.find(@f1).has_data_in_range?(nil, Date.parse("2011-03-01")).should be_true
        DataFile.find(@f2).has_data_in_range?(nil, Date.parse("2011-03-01")).should be_true
        DataFile.find(@f3).has_data_in_range?(nil, Date.parse("2011-03-01")).should be_true
        DataFile.find(@f4).has_data_in_range?(nil, Date.parse("2011-03-01")).should be_true
        DataFile.find(@f5).has_data_in_range?(nil, Date.parse("2011-03-01")).should be_true
        DataFile.find(@f6).has_data_in_range?(nil, Date.parse("2011-03-01")).should be_false
        DataFile.find(@f8).has_data_in_range?(nil, Date.parse("2011-03-01")).should be_false
      end
      it "should work with range" do
        DataFile.find(@f1).has_data_in_range?(Date.parse("2010-01-01"), Date.parse("2011-02-01")).should be_true
        DataFile.find(@f2).has_data_in_range?(Date.parse("2010-01-01"), Date.parse("2011-02-01")).should be_true
        DataFile.find(@f3).has_data_in_range?(Date.parse("2010-01-01"), Date.parse("2011-02-01")).should be_true
        DataFile.find(@f4).has_data_in_range?(Date.parse("2010-01-01"), Date.parse("2011-02-01")).should be_false
        DataFile.find(@f5).has_data_in_range?(Date.parse("2010-01-01"), Date.parse("2011-02-01")).should be_true
        DataFile.find(@f6).has_data_in_range?(Date.parse("2010-01-01"), Date.parse("2011-02-01")).should be_false
        DataFile.find(@f8).has_data_in_range?(Date.parse("2010-01-01"), Date.parse("2011-02-01")).should be_false
      end
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
      Factory(:data_file).metadata_items.create!(:key => "station_name", :value => "code2")
      Factory(:data_file).metadata_items.create!(:key => "station_name", :value => "ROS_WS")
      Factory(:data_file).metadata_items.create!(:key => "station_name", :value => "code2")
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

  describe "Getting set of column headings for searching" do
    it "Should include all mapped headers as well as unmapped headers from existing files" do
      df1 = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfl", :data_file => df1)
      Factory(:column_detail, :name => "Temp", :data_file => df1)
      Factory(:column_detail, :name => "Humi", :data_file => df1)

      df2 = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfll", :data_file => df2)
      Factory(:column_detail, :name => "SoilTemp", :data_file => df2)
      Factory(:column_detail, :name => "Humi", :data_file => df2)

      Factory(:column_mapping, :name => "Rainfall", :code => "Rnfl")
      Factory(:column_mapping, :name => "Rainfall", :code => "Rnfll")
      Factory(:column_mapping, :name => "Temperature", :code => "Temp")
      Factory(:column_mapping, :name => "Wind Speed", :code => "Wind")

      searchables = DataFile.searchable_column_names
      searchables.should eq(["Humi", "Rainfall", "SoilTemp", "Temperature", "Wind Speed"])
    end
  end

  describe "Find files with variables" do
    before(:each) do
      @f1 = Factory(:data_file)
      @f2 = Factory(:data_file)
      @f3 = Factory(:data_file)
      @f4 = Factory(:data_file)
      @f5 = Factory(:data_file)
      @f6 = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfll", :data_file => @f1)
      Factory(:column_detail, :name => "Temp", :data_file => @f1)
      Factory(:column_detail, :name => "Humi", :data_file => @f1)
      Factory(:column_detail, :name => "Rnfl", :data_file => @f2)
      Factory(:column_detail, :name => "Rnfll", :data_file => @f3)
      Factory(:column_detail, :name => "Temp", :data_file => @f4)
      Factory(:column_detail, :name => "Blah", :data_file => @f5)
    end

    it "when column name is unmapped, should find files with matching column name" do
      DataFile.with_any_of_these_columns(["Rnfll"]).collect(&:id).sort.should eq([@f1.id, @f3.id])
    end

    it "should work with multiple column names" do
      DataFile.with_any_of_these_columns(["Rnfll", "Temp"]).collect(&:id).sort.should eq([@f1.id, @f3.id, @f4.id])
    end

    it "should handle mapped column names" do
      Factory(:column_mapping, :code => "Rnfl", :name => "Rainfall")
      Factory(:column_mapping, :code => "Rnfll", :name => "Rainfall")
      DataFile.with_any_of_these_columns(["Rainfall"]).collect(&:id).sort.should eq([@f1.id, @f2.id, @f3.id])
    end

    it "should handle multiple mapped column names" do
      Factory(:column_mapping, :code => "Rnfl", :name => "Rainfall")
      Factory(:column_mapping, :code => "Rnfll", :name => "Rainfall")
      Factory(:column_mapping, :code => "Temp", :name => "Temperature")
      DataFile.with_any_of_these_columns(["Rainfall", "Temperature"]).collect(&:id).sort.should eq([@f1.id, @f2.id, @f3.id, @f4.id])
    end

    it "should handle a mixture of mapped and unmapped column names" do
      Factory(:column_mapping, :code => "Rnfl", :name => "Rainfall")
      Factory(:column_mapping, :code => "Rnfll", :name => "Rainfall")
      DataFile.with_any_of_these_columns(["Rainfall", "Temp"]).collect(&:id).sort.should eq([@f1.id, @f2.id, @f3.id, @f4.id])
    end

    it "should handle case where a mapped name is also a raw name" do
      pending("Not sure how this should work")
      #Factory(:column_mapping, :code => "Rnfll", :name => "Rainfall")
      #Factory(:column_details, :name => "Rainfall", :data_file => @f5)
      #DataFile.with_any_of_these_columns(["Rainfall"]).collect(&:id).sort.should eq([@f1.id, @f3.id, ??])
    end
  end

  describe "Is known format method" do
    it "should return true only if format attribute is set" do
      Factory(:data_file, :format => nil).known_format?.should be_false
      Factory(:data_file, :format => 'asdf').known_format?.should be_true
      Factory(:data_file, :format => "TOA5").known_format?.should be_true
    end
  end

  describe "Is known format method" do
    it "should return true only if format attribute is set" do
      Factory(:data_file, :format => nil).known_format?.should be_false
      Factory(:data_file, :format => 'asdf').known_format?.should be_true
      Factory(:data_file, :format => "TOA5").known_format?.should be_true
    end
  end

  describe "Column Mappings" do
    it "should return true if there are columns which are unmapped" do
      @data_file = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfll", :data_file => @data_file)
      Factory(:column_detail, :name => "Temp", :data_file => @data_file)
      @data_file.cols_unmapped?.should eq(true)
    end

    it "should return false if all columns mapped" do
      @data_file = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfll", :data_file => @data_file)
      Factory(:column_detail, :name => "Temp", :data_file => @data_file)
      Factory(:column_mapping, :code => "Rnfll")
      Factory(:column_mapping, :code => "Temp")
      @data_file.cols_unmapped?.should eq(false)

    end
  end

  describe "Deleting Files/data" do
    it "should not leave the deleted file behind" do
      pending
      #cuke steps exist to handle uploading a real file, so this test will exist in cuke
    end
    it "should remove only/all column details associated with a file from the database" do
      df1 = Factory(:data_file)
      df1_cols = []
      df1_cols << Factory(:column_detail, :name => "Rnfl", :data_file => df1)
      df1_cols << Factory(:column_detail, :name => "Temp", :data_file => df1)

      df2 = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfl", :data_file => df2)
      Factory(:column_detail, :name => "SoilTemp", :data_file => df2)

      all_cols = ColumnDetail.all
      df1.destroy
      ColumnDetail.all.should eq  (all_cols - df1_cols)
    end

    it "should not remove any column mappings defined from columns in a deleted file" do
      df1 = Factory(:data_file)
      Factory(:column_detail, :name => "Rnfl", :data_file => df1)
      Factory(:column_detail, :name => "Temp", :data_file => df1)
      Factory(:column_mapping, :name => "Rainfall", :code => "Rnfl")
      Factory(:column_mapping, :name => "Temperature", :code => "Temp")

      searchables = DataFile.searchable_column_names
      searchables.should eq(["Rainfall","Temperature"])

      df1.destroy

      searchables = DataFile.searchable_column_names
      searchables.should eq(["Rainfall","Temperature"])
    end

    it "should remove all metadata records associated with a file from the database" do
      df1 = Factory(:data_file)
      df2 = Factory(:data_file)
      df3 = Factory(:data_file)

      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "ABC", :data_file => df1)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "ABC", :data_file => df2)
      Factory(:metadata_item, :key => MetadataKeys::STATION_NAME_KEY, :value => "ABC", :data_file => df3)


      DataFile.with_station_name_in(["ABC"]).collect(&:id).sort.should eq([df1.id, df2.id, df3.id])
      df1.destroy
      DataFile.with_station_name_in(["ABC"]).collect(&:id).sort.should eq([df2.id, df3.id])
      MetadataItem.find_by_data_file_id(df1).should eq nil
    end

  end

end
