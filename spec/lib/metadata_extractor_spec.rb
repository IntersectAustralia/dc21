require 'spec_helper'

describe FileTypeDeterminer do

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

  describe "assign time metadata" do
    it "should call the Toa5Parser.assign_time_metadata on the datafile" do
      Toa5Parser.should_receive(:assign_time_metadata).with(unsaved_toa5_dat)

      metadata_extractor.assign_time_metadata(unsaved_toa5_dat, FileTypeDeterminer::TOA5)

      unsaved_toa5_dat.should_not be_persisted
    end
    it "doesn't call Toa5Parser if it's not a TOA5" do
      Toa5Parser.should_not_receive(:assign_time_metadata)

      metadata_extractor.assign_time_metadata(unsaved_toa5_dat, "garbage")

      unsaved_toa5_dat.should_not be_persisted
    end
  end

end
