require 'spec_helper'

describe AttachmentBuilder do

  let(:file1) {
    Rack::Test::UploadedFile.new(Rails.root.join("spec/samples", 'toa5.dat'), 'text/plain')
  }

  let(:file2) {
    Rack::Test::UploadedFile.new(Rails.root.join("spec/samples", 'sample'), 'text/plain')
  }

  let(:files_root) {
    Rails.root.join('tmp')
  }

  describe "Building attachments" do

    it "should create new data file object with correct experiment, type, description and size" do
      file_type_determiner = mock(FileTypeDeterminer)
      file_type_determiner.should_receive(:identify_file).and_return(nil)
      user = Factory(:user)
      ab = AttachmentBuilder.new(files_root, user, file_type_determiner, nil)
      data_file = ab.build(file1, 23, DataFile::STATUS_RAW, "my desc")

      DataFile.count.should eq(1)
      data_file.messages.should eq([{:type => :success, :message => "File uploaded successfully."}])
      data_file.filename.should == "toa5.dat"
      data_file.created_by.should eq(user)
      data_file.experiment_id.should eq(23)
      data_file.file_processing_status.should eq(DataFile::STATUS_RAW)
      data_file.file_processing_description.should eq("my desc")
      data_file.file_size.should eq(717397) #size in bytes of the sample file being used
    end

    it "should extract metadata if file type is recognised" do
      file_type_determiner = mock(FileTypeDeterminer)
      metadata_extractor = mock(MetadataExtractor)
      file_type_determiner.should_receive(:identify_file).and_return(FileTypeDeterminer::TOA5)
      metadata_extractor.should_receive(:extract_metadata)

      file_type_determiner
      ab = AttachmentBuilder.new(files_root, Factory(:user), file_type_determiner, metadata_extractor)
      data_file = ab.build(file1, 23, DataFile::STATUS_RAW, "my desc")

      DataFile.count.should eq(1)
      data_file.messages.should eq([{:type => :success, :message => "File uploaded successfully."}])
      data_file.filename.should == "toa5.dat"
      data_file.format.should == "TOA5"
    end

    it "should not extract metadata if file type is unknown" do
      file_type_determiner = mock(FileTypeDeterminer)
      metadata_extractor = mock(MetadataExtractor)
      file_type_determiner.should_receive(:identify_file).and_return(nil)
      metadata_extractor.should_not_receive(:extract_metadata)

      file_type_determiner
      ab = AttachmentBuilder.new(files_root, Factory(:user), file_type_determiner, metadata_extractor)
      data_file = ab.build(file1, 23, DataFile::STATUS_RAW, "my desc")

      DataFile.count.should eq(1)
      data_file.messages.should eq([{:type => :success, :message => "File uploaded successfully."}])
      data_file.filename.should == "toa5.dat"
      data_file.format.should be_nil
    end

    describe "file name should be suffixed with a number if it already exists" do
      let(:file_type_determiner) do
        file_type_determiner = mock(FileTypeDeterminer)
        file_type_determiner.should_receive(:identify_file).and_return(nil)
        file_type_determiner
      end

      let(:ab) { AttachmentBuilder.new(files_root, Factory(:user), file_type_determiner, nil) }

      it "should add a numeric suffix if name already exists" do
        Factory(:data_file, :filename => "toa5.dat")
        data_file = ab.build(file1, 23, DataFile::STATUS_RAW, "my desc")
        data_file.filename.should eq("toa5_1.dat")
        data_file.messages.should eq([{:type => :info, :message => "A file already existed with the same name. File has been renamed."}])
      end

      it "should add a numeric suffix if name already exists and file has no extension" do
        Factory(:data_file, :filename => "sample")
        data_file = ab.build(file2, 23, DataFile::STATUS_RAW, "my desc")
        data_file.filename.should eq("sample_1")
        data_file.messages.should eq([{:type => :info, :message => "A file already existed with the same name. File has been renamed."}])
      end

      it "should allow 2 files with same name but different extension" do
        Factory(:data_file, :filename => "toa5.txt")
        data_file = ab.build(file1, 23, DataFile::STATUS_RAW, "my desc")
        data_file.filename.should eq("toa5.dat")
        data_file.messages.should eq([{:type => :success, :message => "File uploaded successfully."}])
      end

      it "should increment the number if name exists and other numbered ones also exist" do
        Factory(:data_file, :filename => "toa5.dat")
        Factory(:data_file, :filename => "toa5_1.dat")
        data_file = ab.build(file1, 23, DataFile::STATUS_RAW, "my desc")
        data_file.filename.should eq("toa5_2.dat")
        data_file.messages.should eq([{:type => :info, :message => "A file already existed with the same name. File has been renamed."}])
      end

      it "should pick first available number if name exists and other numbered ones also exist - with gaps" do
        Factory(:data_file, :filename => "toa5.dat")
        Factory(:data_file, :filename => "toa5_1.dat")
        Factory(:data_file, :filename => "toa5_2.dat")
        Factory(:data_file, :filename => "toa5_11.dat")
        Factory(:data_file, :filename => "toa5_20121212.dat")
        data_file = ab.build(file1, 23, DataFile::STATUS_RAW, "my desc")
        data_file.filename.should eq("toa5_3.dat")
        data_file.messages.should eq([{:type => :info, :message => "A file already existed with the same name. File has been renamed."}])
      end

      it "should pick first available number if name exists and other numbered ones also exist - no gaps" do
        Factory(:data_file, :filename => "toa5.dat")
        Factory(:data_file, :filename => "toa5_1.dat")
        Factory(:data_file, :filename => "toa5_2.dat")
        Factory(:data_file, :filename => "toa5_3.dat")
        data_file = ab.build(file1, 23, DataFile::STATUS_RAW, "my desc")
        data_file.filename.should eq("toa5_4.dat")
        data_file.messages.should eq([{:type => :info, :message => "A file already existed with the same name. File has been renamed."}])
      end

      it "should pick first available number if name exists and other numbered ones also exist and no extension" do
        Factory(:data_file, :filename => "sample")
        Factory(:data_file, :filename => "sample_1")
        Factory(:data_file, :filename => "sample_2")
        Factory(:data_file, :filename => "sample_11")
        Factory(:data_file, :filename => "sample_20121212")
        data_file = ab.build(file2, 23, DataFile::STATUS_RAW, "my desc")
        data_file.filename.should eq("sample_3")
        data_file.messages.should eq([{:type => :info, :message => "A file already existed with the same name. File has been renamed."}])
      end

    end

    after(:each) do
      DataFile.all.each do |df|
        FileUtils.rm_rf(df.filename) if File.exists?(df.filename)
      end
    end

  end

end
