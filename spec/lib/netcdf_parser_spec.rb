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

  let(:netcdf_timeseries_nc) do
    path = Rails.root.join('spec/samples', 'netcdf_double_series.nc')
    Factory(:data_file, :path => path, :filename => 'netcdf_double_series.nc')
  end

  describe "valid file" do

    it "should extract the column header from the file" do
      data_file = netcdf_nc
      NetcdfParser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload

      headers = data_file.column_details
      metadata_items = data_file.metadata_items
      check_df_attrs(data_file, '1990-08-01 00:00', '1990-08-01 00:00')
      check_headers(headers)
      check_metadata(metadata_items)
    end

    it "should extract the column header from file with spaces" do
      data_file = netcdf_2_nc
      NetcdfParser.extract_metadata(data_file)
      # reload to make sure it survives being persisted
      data_file.reload

      headers = data_file.column_details
      metadata_items = data_file.metadata_items
      check_headers(headers)
      check_metadata(metadata_items)
    end

    it "should have an id with start and end time appended to it" do
      data_file = netcdf_nc
      NetcdfParser.extract_metadata(data_file)
      data_file.reload
      data_file.external_id.should eq("eMAST_eWATCH_day_prec_v1m0_1979_2012__1990-08-01 00:00_1990-08-01 00:00")
    end

    it "should have start and end time properly extracted if it's a time series datafile" do
      data_file = netcdf_timeseries_nc
      NetcdfParser.extract_metadata(data_file)
      data_file.reload
      check_df_attrs(data_file, '1950-01-01 12:00', '2009-01-01 12:00')
    end

  end

  private

  def check_df_attrs(data_file, start_time, end_time)
    data_file.start_time.strftime('%Y-%m-%d %H:%M').should eq(start_time)
    data_file.end_time.strftime('%Y-%m-%d %H:%M').should eq(end_time)
  end

  def check_headers(headers)
    headers.length.should eq(5)
    elem = headers[0]
    elem.name.should eq("time")
    elem.unit.should eq("seconds since 1970-01-01 00:00:00")
    elem.data_type.should be_nil
    elem.fill_value.should be_nil
    elem.position.should eq(0)

    elem = headers[1]
    elem.name.should eq("latitude")
    elem.unit.should eq("degrees_north")
    elem.data_type.should be_nil
    elem.fill_value.should be_nil
    elem.position.should eq(1)

    elem = headers[2]
    elem.name.should eq("longitude")
    elem.unit.should eq("degrees_east")
    elem.data_type.should be_nil
    elem.fill_value.should be_nil
    elem.position.should eq(2)

    elem = headers[3]
    elem.name.should eq("convective_precipitation_flux")
    elem.unit.should eq("mm")
    elem.data_type.should eq("day")
    elem.fill_value.should eq("-9999.")
    elem.position.should eq(3)

    elem = headers[4]
    elem.name.should eq("crs")
    elem.unit.should be_nil
    elem.data_type.should be_nil
    elem.fill_value.should be_nil
    elem.position.should eq(4)
  end

  def check_metadata(metadata_items)
    metadata_items.length.should eq(41)
  end

end