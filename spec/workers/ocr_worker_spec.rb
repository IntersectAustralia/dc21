require 'spec_helper'

describe OCRWorker do

  describe "Error messages" do
    it "should raise error if Tesseract is not installed" do
      parent = Factory(:data_file, filename: "abc.jpg", format: "image/jpeg")
      # use attachment builder here
      output = Factory(:data_file, filename: "abc.txt", format: "plain/text", uuid: "test")

      RestClient.stub(:post).and_return(1,2,3,4,5,6)

      worker = OCRWorker.new({output_id: output.id, parent_id: parent.id})
      worker.stub(:tesseract_installed?).and_return(false)
      DataFile.stub(:find).and_return(output,parent)
      Resque::Plugins::Status::Hash.stub(:get).and_return(Resque::Plugins::Status::Hash.new(status: "WORKING"))
      expect { worker.perform }.to raise_error

      # check output file processing description
      # check output file contains text from stubbed xml

    end

  end
end
