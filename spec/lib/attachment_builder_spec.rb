require 'spec_helper'

describe AttachmentBuilder do

  let(:file1) {
    Rack::Test::UploadedFile.new(Rails.root.join("spec/samples", 'file.a'), 'text/plain')
  }
  let(:file2) {
    Rack::Test::UploadedFile.new(Rails.root.join("spec/samples", 'file.b'), 'text/plain')
  }
  let(:file3) {
    Rack::Test::UploadedFile.new(Rails.root.join("spec/samples", 'file.c'), 'text/plain')
  }

  let(:files_root) {
    Rails.root.join('tmp')
  }

  let(:applet_params) {
    {
        :dirStruct => '[{"file_1":"file.a"}]',
        :destDir => "/",
        :file_1 => file1
    }
  }

  describe "Building attachments" do

    it "should create new data file objects" do
      file_type_determiner = mock(FileTypeDeterminer)
      file_type_determiner.should_receive(:identify_file).and_return([false, nil])
      ab = AttachmentBuilder.new(applet_params, files_root, nil, file_type_determiner, nil)
      result = ab.build
      result.include?("file.a").should be_true
      result["file.a"][:status].should == "success"

      DataFile.count.should eq(1)
      data_file = DataFile.first
      data_file.filename.should == "file.a"
    end

    it "should extract metadata if file type is recognised" do
      file_type_determiner = mock(FileTypeDeterminer)
      metadata_extractor = mock(MetadataExtractor)
      file_type_determiner.should_receive(:identify_file).and_return([true, FileTypeDeterminer::TOA5])
      metadata_extractor.should_receive(:extract_metadata)

      file_type_determiner
      ab = AttachmentBuilder.new(applet_params, files_root, nil, file_type_determiner, metadata_extractor)
      result = ab.build
      result.include?("file.a").should be_true
      result["file.a"][:status].should == "success"

      DataFile.count.should eq(1)
      data_file = DataFile.first
      data_file.filename.should == "file.a"
      data_file.format.should == "TOA5"
    end

    it "should not extract metadata if file type is unknown" do
      file_type_determiner = mock(FileTypeDeterminer)
      metadata_extractor = mock(MetadataExtractor)
      file_type_determiner.should_receive(:identify_file).and_return([false, nil])
      metadata_extractor.should_not_receive(:extract_metadata)

      file_type_determiner
      ab = AttachmentBuilder.new(applet_params, files_root, nil, file_type_determiner, metadata_extractor)
      result = ab.build
      result.include?("file.a").should be_true
      result["file.a"][:status].should == "success"

      DataFile.count.should eq(1)
      data_file = DataFile.first
      data_file.filename.should == "file.a"
      data_file.format.should be_nil
    end

    after(:each) do
      DataFile.all.each do |df|
        FileUtils.rm_rf(df.filename) if File.exists?(df.filename)
      end
    end

  end

end
