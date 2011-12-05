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

  describe "Building attachments" do

    it "should create new data file objects" do
      params = {
        :dirStruct => '[{"file_1":"file.a"}]',
        :destDir => "/",
        :file_1 => file1
      }
      ab = AttachmentBuilder.new(params, files_root, nil)
      result = ab.build
      result.include?("file.a").should be_true
      result["file.a"][:status].should == "success"

      DataFile.count.should eq(1)
      data_file = DataFile.first
      data_file.filename.should == "file.a"
    end

    after(:each) do
      DataFile.all.each do |df|
        FileUtils.rm_rf(df.filename) if File.exists?(df.filename)
      end
    end

  end

end
