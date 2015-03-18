require 'spec_helper'

describe MetadataExtractor do

  let(:toa5_dat) do
    path = Rails.root.join('spec/samples', 'toa5.dat')
    Factory(:data_file, :path => path, :filename => 'toa5.dat')
  end

  let(:unsaved_toa5_dat) do
    path = Rails.root.join('spec/samples', 'toa5.dat')
    Factory.build(:data_file, :path => path, :filename => 'toa5.dat')
  end

  let(:metadata_extractor) {
    MetadataExtractor.new
  }

  let(:netcdf_nc) do
    path = Rails.root.join('spec/samples', 'netcdf.nc')
    Factory(:data_file, :path => path, :filename => 'netcdf.nc')
  end

  let(:netcdf_ncml) do
    path = Rails.root.join('spec/samples', 'netcdf.ncml')
    Factory(:data_file, :path => path, :filename => 'netcdf.ncml')
  end

  describe "Should delegate to the correct parser" do
    it "should use the TOA5 parser if file is TOA5" do
      Toa5Parser.should_receive(:extract_metadata)
      metadata_extractor.extract_metadata(toa5_dat, FileTypeDeterminer::TOA5)
    end

    it "should do nothing otherwise" do
      Toa5Parser.should_not_receive(:extract_metadata)
      metadata_extractor.extract_metadata(nil, "blah")
    end

    it "should use the Netcdf parser if file is NetCDF" do
      NetcdfParser.should_receive(:extract_metadata)
      metadata_extractor.extract_metadata(netcdf_nc, FileTypeDeterminer::NETCDF)
    end

    it "should use the NCML parser if file is NCML" do
      NcmlParser.should_receive(:extract_metadata)
      metadata_extractor.extract_metadata(netcdf_ncml, FileTypeDeterminer::NCML)
    end
  end

end
