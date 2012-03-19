require 'spec_helper'

describe AttachmentBuilder do

  let(:file1) {
    Rack::Test::UploadedFile.new(Rails.root.join("spec/samples", 'file.a'), 'text/plain')
  }

  let(:files_root) {
    Rails.root.join('tmp')
  }

  describe "Building attachments" do

    it "should create new data file object with correct experiment and type" do
      file_type_determiner = mock(FileTypeDeterminer)
      file_type_determiner.should_receive(:identify_file).and_return(nil)
      user = Factory(:user)
      ab = AttachmentBuilder.new(files_root, user, file_type_determiner, nil)
      data_file = ab.build(file1, 23, DataFile::STATUS_RAW)

      DataFile.count.should eq(1)
      data_file.messages.should eq(["File uploaded successfully"])
      data_file.filename.should == "file.a"
      data_file.created_by.should eq(user)
      data_file.experiment_id.should eq(23)
      data_file.file_processing_status.should eq(DataFile::RAW)
    end

    it "should extract metadata if file type is recognised" do
      file_type_determiner = mock(FileTypeDeterminer)
      metadata_extractor = mock(MetadataExtractor)
      file_type_determiner.should_receive(:identify_file).and_return(FileTypeDeterminer::TOA5)
      metadata_extractor.should_receive(:extract_metadata)

      file_type_determiner
      ab = AttachmentBuilder.new(files_root, Factory(:user), file_type_determiner, metadata_extractor)
      data_file = ab.build(file1, 23, DataFile::STATUS_RAW)

      DataFile.count.should eq(1)
      data_file.messages.should eq(["File uploaded successfully"])
      data_file.filename.should == "file.a"
      data_file.format.should == "TOA5"
    end

    it "should not extract metadata if file type is unknown" do
      file_type_determiner = mock(FileTypeDeterminer)
      metadata_extractor = mock(MetadataExtractor)
      file_type_determiner.should_receive(:identify_file).and_return(nil)
      metadata_extractor.should_not_receive(:extract_metadata)

      file_type_determiner
      ab = AttachmentBuilder.new(files_root, Factory(:user), file_type_determiner, metadata_extractor)
      data_file = ab.build(file1, 23, DataFile::STATUS_RAW)

      DataFile.count.should eq(1)
      data_file.messages.should eq(["File uploaded successfully"])
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
