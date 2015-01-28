require 'spec_helper'

describe NetcdfParser do

  let(:netcdf_nc) do
    path = Rails.root.join('spec/samples', 'netcdf.nc')
    Factory(:data_file, :path => path, :filename => 'netcdf.nc')
  end

  let(:netcdf_2_nc) do
    path = Rails.root.join('spec/samples', 'netcdf 2 (1).nc')
    Factory(:data_file, :path => path, :filename => 'netcdf 2 (1).nc')
  end

  describe "valid file" do

    it "should extract the column header from the file" do
      data_file = netcdf_nc
      NetcdfParser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload

      headers = data_file.column_details
      headers.length.should eq(5)
      elem = headers[0]
      elem.name.should eq("time")
      elem.unit.should eq("seconds since 1970-01-01 00:00:00")
      elem.data_type.should be_nil
      elem.position.should eq(0)

      elem = headers[1]
      elem.name.should eq("latitude")
      elem.unit.should eq("degrees_north")
      elem.data_type.should be_nil
      elem.position.should eq(1)

      elem = headers[2]
      elem.name.should eq("longitude")
      elem.unit.should eq("degrees_east")
      elem.data_type.should be_nil
      elem.position.should eq(2)

      elem = headers[3]
      elem.name.should eq("convective_precipitation_flux")
      elem.unit.should eq("mm")
      elem.data_type.should eq("day")
      elem.position.should eq(3)

      elem = headers[4]
      elem.name.should eq("crs")
      elem.unit.should be_nil
      elem.data_type.should be_nil
      elem.position.should eq(4)
    end

    it "should extract the column header from file with spaces" do
      data_file = netcdf_2_nc
      NetcdfParser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload

      headers = data_file.column_details
      headers.length.should eq(5)
      elem = headers[0]
      elem.name.should eq("time")
      elem.unit.should eq("seconds since 1970-01-01 00:00:00")
      elem.data_type.should be_nil
      elem.position.should eq(0)

      elem = headers[1]
      elem.name.should eq("latitude")
      elem.unit.should eq("degrees_north")
      elem.data_type.should be_nil
      elem.position.should eq(1)

      elem = headers[2]
      elem.name.should eq("longitude")
      elem.unit.should eq("degrees_east")
      elem.data_type.should be_nil
      elem.position.should eq(2)

      elem = headers[3]
      elem.name.should eq("convective_precipitation_flux")
      elem.unit.should eq("mm")
      elem.data_type.should eq("day")
      elem.position.should eq(3)

      elem = headers[4]
      elem.name.should eq("crs")
      elem.unit.should be_nil
      elem.data_type.should be_nil
      elem.position.should eq(4)
    end

  end

end