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

  describe "Search by date" do
    it "should return files for which the date range covers the given date" do
      f1 = Factory(:data_file, :start_time => "2011-12-20 11:00 UTC", :end_time => "2011-12-25 11:00 UTC") # starts before, ends after = IN
      f2 = Factory(:data_file, :start_time => "2011-12-24 11:00 UTC", :end_time => "2011-12-25 11:00 UTC") # starts on, ends after = IN
      f3 = Factory(:data_file, :start_time => "2011-12-24 23:59 UTC", :end_time => "2011-12-25 11:00 UTC") # starts on, ends after = IN
      f4 = Factory(:data_file, :start_time => "2011-12-25 00:00 UTC", :end_time => "2011-12-25 11:00 UTC") # starts after, ends after = OUT
      f5 = Factory(:data_file, :start_time => "2011-12-20 11:00 UTC", :end_time => "2011-12-23 23:59 UTC") # starts before, ends before = OUT
      f6 = Factory(:data_file, :start_time => "2011-12-20 11:00 UTC", :end_time => "2011-12-24 00:00 UTC") # starts before, ends on = IN
      f7 = Factory(:data_file, :start_time => "2011-12-20 11:00 UTC", :end_time => "2011-12-24 11:00 UTC") # starts before, end on = IN
      f8 = Factory(:data_file, :start_time => nil, :end_time => nil)

      search_result = DataFile.search_by_date(Date.parse("2011-12-24"))
      search_result.size.should eq(5)
      search_result.collect(&:id).sort.should eq([f1.id, f2.id, f3.id, f6.id, f7.id])
    end
  end
end
