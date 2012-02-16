require 'spec_helper'

#TODO: currently depends on the real API
describe ForCodesLookup do
  it "Get top level codes should return an array of top level codes" do
    lookup = ForCodesLookup.new
    codes = lookup.top_level_codes
    codes.size.should eq(22)
    codes[0].should eq(["01 - MATHEMATICAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/01"])
    codes[6].should eq(["07 - AGRICULTURAL AND VETERINARY SCIENCES", "http://purl.org/asc/1297.0/2008/for/07"])
    codes[21].should eq(["22 - PHILOSOPHY AND RELIGIOUS STUDIES", "http://purl.org/asc/1297.0/2008/for/22"])
  end

  it "should be able to get second level codes based on a top level code" do
    lookup = ForCodesLookup.new
    codes = lookup.second_level_codes("http://purl.org/asc/1297.0/2008/for/07")
    codes.size.should eq(8)
    codes[0].should eq(["0701 - Agriculture, Land and Farm Management", "http://purl.org/asc/1297.0/2008/for/0701"])
    codes[7].should eq(["0799 - Other Agricultural and Veterinary Sciences", "http://purl.org/asc/1297.0/2008/for/0799"])
  end

  it "should be able to get third level codes based on a second level code" do
    lookup = ForCodesLookup.new
    codes = lookup.third_level_codes("http://purl.org/asc/1297.0/2008/for/0701")
    codes.size.should eq(9)
    codes[0].should eq(["070101 - Agricultural Land Management", "http://purl.org/asc/1297.0/2008/for/070101"])
    codes[8].should eq(["070199 - Agriculture, Land and Farm Management not elsewhere classified", "http://purl.org/asc/1297.0/2008/for/070199"])
  end
end