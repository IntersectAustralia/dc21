require 'spec_helper'

describe Toa5Utilities do

  describe "Parse time" do
    it "should parse times that match the formats used in TOA5" do
      Toa5Utilities.parse_time("8/10/2011 9:55").to_s.should eq("2011-10-08 09:55:00 UTC")
      Toa5Utilities.parse_time("8/10/2011 10:00").to_s.should eq("2011-10-08 10:00:00 UTC")
      Toa5Utilities.parse_time("12/10/2011 1:50").to_s.should eq("2011-10-12 01:50:00 UTC")
      Toa5Utilities.parse_time("13/10/2011 22:25").to_s.should eq("2011-10-13 22:25:00 UTC")
      Toa5Utilities.parse_time("2011-08-11 09:30:00").to_s.should eq("2011-08-11 09:30:00 UTC")
    end

    #it "should reject others" do
    #  Toa5Utilities.parse_time("8/10/2011 9:55 AM")
    #  Toa5Utilities.parse_time("8/10/11 9:55")
    #  Toa5Utilities.parse_time("8/13/11 9:55")
    #  Toa5Utilities.parse_time("8/13/11")
    #  Toa5Utilities.parse_time("Junk")
    #end
  end
end
