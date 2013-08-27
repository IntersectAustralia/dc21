require 'spec_helper'

#TODO: currently depends on the real API
describe ForCodesLookup do
  it "Get top level codes should return an array of top level codes" do
    lookup = ForCodesLookup.new
    lookup.stub('top_level_codes').and_return([["01 - MATHEMATICAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/01"], ["02 - PHYSICAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/02"], ["03 - CHEMICAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/03"], ["04 - EARTH SCIENCES", "http://purl.org/asc/1297.0/2008/for/04"], ["05 - ENVIRONMENTAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/05"], ["06 - BIOLOGICAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/06"], ["07 - AGRICULTURAL AND VETERINARY SCIENCES", "http://purl.org/asc/1297.0/2008/for/07"], ["08 - INFORMATION AND COMPUTING SCIENCES", "http://purl.org/asc/1297.0/2008/for/08"], ["09 - ENGINEERING", "http://purl.org/asc/1297.0/2008/for/09"], ["10 - TECHNOLOGY", "http://purl.org/asc/1297.0/2008/for/10"], ["11 - MEDICAL AND HEALTH SCIENCES", "http://purl.org/asc/1297.0/2008/for/11"], ["12 - BUILT ENVIRONMENT AND DESIGN", "http://purl.org/asc/1297.0/2008/for/12"], ["13 - EDUCATION", "http://purl.org/asc/1297.0/2008/for/13"], ["14 - ECONOMICS", "http://purl.org/asc/1297.0/2008/for/14"], ["15 - COMMERCE, MANAGEMENT, TOURISM AND SERVICES", "http://purl.org/asc/1297.0/2008/for/15"], ["16 - STUDIES IN HUMAN SOCIETY", "http://purl.org/asc/1297.0/2008/for/16"], ["17 - PSYCHOLOGY AND COGNITIVE SCIENCES", "http://purl.org/asc/1297.0/2008/for/17"], ["18 - LAW AND LEGAL STUDIES", "http://purl.org/asc/1297.0/2008/for/18"], ["19 - STUDIES IN CREATIVE ARTS AND WRITING", "http://purl.org/asc/1297.0/2008/for/19"], ["20 - LANGUAGE, COMMUNICATION AND CULTURE", "http://purl.org/asc/1297.0/2008/for/20"], ["21 - HISTORY AND ARCHAEOLOGY", "http://purl.org/asc/1297.0/2008/for/21"], ["22 - PHILOSOPHY AND RELIGIOUS STUDIES", "http://purl.org/asc/1297.0/2008/for/22"]])
    codes = lookup.top_level_codes
    codes.size.should eq(22)
    codes[0].should eq(["01 - MATHEMATICAL SCIENCES", "http://purl.org/asc/1297.0/2008/for/01"])
    codes[6].should eq(["07 - AGRICULTURAL AND VETERINARY SCIENCES", "http://purl.org/asc/1297.0/2008/for/07"])
    codes[21].should eq(["22 - PHILOSOPHY AND RELIGIOUS STUDIES", "http://purl.org/asc/1297.0/2008/for/22"])
  end

  it "should be able to get second level codes based on a top level code" do
    lookup = ForCodesLookup.new
    lookup.stub('second_level_codes').with('http://purl.org/asc/1297.0/2008/for/07').and_return([["0701 - Agriculture, Land and Farm Management", "http://purl.org/asc/1297.0/2008/for/0701"], ["0702 - Animal Production", "http://purl.org/asc/1297.0/2008/for/0702"], ["0703 - Crop and Pasture Production", "http://purl.org/asc/1297.0/2008/for/0703"], ["0704 - Fisheries Sciences", "http://purl.org/asc/1297.0/2008/for/0704"], ["0705 - Forestry Sciences", "http://purl.org/asc/1297.0/2008/for/0705"], ["0706 - Horticultural Production", "http://purl.org/asc/1297.0/2008/for/0706"], ["0707 - Veterinary Sciences", "http://purl.org/asc/1297.0/2008/for/0707"], ["0799 - Other Agricultural and Veterinary Sciences", "http://purl.org/asc/1297.0/2008/for/0799"]])
    codes = lookup.second_level_codes("http://purl.org/asc/1297.0/2008/for/07")
    codes.size.should eq(8)
    codes[0].should eq(["0701 - Agriculture, Land and Farm Management", "http://purl.org/asc/1297.0/2008/for/0701"])
    codes[7].should eq(["0799 - Other Agricultural and Veterinary Sciences", "http://purl.org/asc/1297.0/2008/for/0799"])
  end

  it "should be able to get third level codes based on a second level code" do
    lookup = ForCodesLookup.new
    lookup.stub('third_level_codes').with('http://purl.org/asc/1297.0/2008/for/0701').and_return([["070101 - Agricultural Land Management", "http://purl.org/asc/1297.0/2008/for/070101"], ["070102 - Agricultural Land Planning", "http://purl.org/asc/1297.0/2008/for/070102"], ["070103 - Agricultural Production Systems Simulation", "http://purl.org/asc/1297.0/2008/for/070103"], ["070104 - Agricultural Spatial Analysis and Modelling", "http://purl.org/asc/1297.0/2008/for/070104"], ["070105 - Agricultural Systems Analysis and Modelling", "http://purl.org/asc/1297.0/2008/for/070105"], ["070106 - Farm Management, Rural Management and Agribusiness", "http://purl.org/asc/1297.0/2008/for/070106"], ["070107 - Farming Systems Research", "http://purl.org/asc/1297.0/2008/for/070107"], ["070108 - Sustainable Agricultural Development", "http://purl.org/asc/1297.0/2008/for/070108"], ["070199 - Agriculture, Land and Farm Management not elsewhere classified", "http://purl.org/asc/1297.0/2008/for/070199"]])
    codes = lookup.third_level_codes("http://purl.org/asc/1297.0/2008/for/0701")
    codes.size.should eq(9)
    codes[0].should eq(["070101 - Agricultural Land Management", "http://purl.org/asc/1297.0/2008/for/070101"])
    codes[8].should eq(["070199 - Agriculture, Land and Farm Management not elsewhere classified", "http://purl.org/asc/1297.0/2008/for/070199"])
  end
end