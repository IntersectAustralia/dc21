require 'spec_helper'

describe DataFilesHelper do
  describe "Getting the grouped list of experiments for a data file" do
    it "includes all facilities in alphabetic order" do
      Factory(:facility, name: "Fred")
      Factory(:facility, name: "Joe")
      Factory(:facility, name: "Alice")

      output = helper.grouped_experiments_for_select
      output.collect(&:name).should eq(["Alice", "Fred", "Joe"])
    end
  end
end
