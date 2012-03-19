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
      expected = 'something'

      toa5_parser = mock(Toa5Parser)
      dat = unsaved_toa5_dat
      toa5_parser.should_receive(:assign_time_metadata_returning_other_metadata).with(dat).and_return(expected)

      MetadataExtractor.const_set(:Toa5Parser, toa5_parser) # This is a bit of a hack.

      actual = metadata_extractor.assign_time_metadata_returning_other_metadata(dat, FileTypeDeterminer::TOA5)

      actual.should eq expected

      dat.should_not be_persisted
    end
    it "doesn't call Toa5Parser if it's not a TOA5" do
      toa5_parser = mock(Toa5Parser)
      MetadataExtractor.const_set(:Toa5Parser, toa5_parser) # This is a bit of a hack.

      dat = unsaved_toa5_dat

      actual = metadata_extractor.assign_time_metadata_returning_other_metadata(dat, "garbage")

      actual.should_not be

      dat.should_not be_persisted
    end
    after(:each) do
      MetadataExtractor.send(:remove_const, :Toa5Parser) # This is a companion hack to the previous hacks
    end
  end

end
