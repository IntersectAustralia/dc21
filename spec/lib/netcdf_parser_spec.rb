require 'spec_helper'

describe NetcdfParser do

  let(:netcdf_nc) do
    path = Rails.root.join('spec/samples', 'netcdf.nc')
    Factory(:data_file, :path => path, :filename => 'netcdf.nc')
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


    end

    it "should extract any :cell_methods variable as Measurement Type" do

    end


    it "should extract frequency according to the cell_methods variable" do

    end



  end

end