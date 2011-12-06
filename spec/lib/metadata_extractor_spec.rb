require 'spec_helper'

describe FileTypeDeterminer do

  let(:toa5_dat) do
    path = Rails.root.join('spec/samples', 'toa5.dat')
    Factory(:data_file, :path => path, :filename => 'toa5.dat')
  end

  let(:metadata_extractor) {
    MetadataExtractor.new
  }

  describe "Should delegate to the correct parser" do
    it "should use the TOA5 parser if file is TOA5" do
      Toa5Parser.should_receive(:extract_metadata)
      metadata_extractor.extract_metadata(toa5_dat, FileTypeDeterminer::TOA5)
    end

    it "should do nothing otherwise" do
      Toa5Parser.should_not_receive(:extract_metadata)
      metadata_extractor.extract_metadata(nil, "blah")
    end
  end

end
