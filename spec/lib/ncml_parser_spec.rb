require 'spec_helper'

describe NcmlParser do

  let(:netcdf_ncml) do
    path = Rails.root.join('spec/samples', 'netcdf.ncml')
    Factory(:data_file, :path => path, :filename => 'netcdf.ncml')
  end


  describe "#extract_metadata" do

    context "when ncml file is valid" do

      it "extracts location as link" do
        NcmlParser.extract_metadata(netcdf_ncml)
        metadata_items = netcdf_ncml.metadata_items
        metadata_items.length.should eq(43)
        metadata_items[0].value.should eq("http://dapds00.nci.org.au/thredds/dodsC/eMAST_TERN/Climate/eMAST/ANUClimate/0_01deg/v1m0_aus/day/land/prec/e_01/1970_2012/eMAST_ANUClimate_day_prec_v1m0_1970_2012_agg.ncml")
      end
    end

  end


end