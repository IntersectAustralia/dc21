require 'spec_helper'

describe Toa5Parser do

  let(:toa5_dat) do
    path = Rails.root.join('spec/samples', 'toa5.dat')
    Factory(:data_file, :path => path, :filename => 'toa5.dat')
  end

  describe "valid file" do
    it "should extract the start date from the file" do
      data_file = toa5_dat
      Toa5Parser.extract_metadata(data_file)
      data_file.start_time.should eq("6/10/2011 0:40")
      data_file.end_time.should eq("3/11/2011 11:55")
    end

    it "should extract datalogger model" do
      data_file = toa5_dat
      Toa5Parser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload
      data_file.metadata[:datalogger_model].should eq("CR3000")
    end
  end
end
