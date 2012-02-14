require 'spec_helper'

describe ForCodesLookup do
  it "Get top level codes should return an array of top level codes" do
    #TODO: currently depends on the real API
    lookup = ForCodesLookup.new
    codes = lookup.top_level_codes
    codes.size.should eq(22)
    codes[0].should eq(["http://purl.org/asc/1297.0/2008/for/01", "01 - MATHEMATICAL SCIENCES"])
    codes[6].should eq(["http://purl.org/asc/1297.0/2008/for/07", "07 - AGRICULTURAL AND VETERINARY SCIENCES"])
    codes[21].should eq(["http://purl.org/asc/1297.0/2008/for/22", "22 - PHILOSOPHY AND RELIGIOUS STUDIES"])
  end
end