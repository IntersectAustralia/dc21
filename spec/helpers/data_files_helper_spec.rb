require 'spec_helper'

describe DataFilesHelper do
  describe "Getting the grouped list of experiments for a data file" do
    it "when data file belongs to no facility, it puts them in alphabetic order" do
      Factory(:facility, name: "Fred")
      Factory(:facility, name: "Joe")
      Factory(:facility, name: "Alice")
      data_file = mock
      data_file.stub(:facility).and_return(nil)

      helper.grouped_experiments_for_select(data_file).collect(&:name).should eq(["Alice", "Fred", "Joe", "Other"])
    end

    it "when data file belongs to a facility, it puts that facility at the top and the rest alphabetic" do
      fred = Factory(:facility, name: "Fred")
      Factory(:facility, name: "Joe")
      Factory(:facility, name: "Alice")
      data_file = mock
      data_file.stub(:facility).and_return(fred)

      helper.grouped_experiments_for_select(data_file).collect(&:name).should eq(["Fred", "Alice", "Joe", "Other"])
    end
  end
end
