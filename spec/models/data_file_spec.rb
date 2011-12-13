require 'spec_helper'

describe DataFile do
  describe "Validations" do
    it { should validate_presence_of(:filename) }
    it { should validate_presence_of(:path) }
    it { should validate_presence_of(:created_by_id) }
  end

  describe "Associations" do
    it { should belong_to(:created_by) }
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
end
