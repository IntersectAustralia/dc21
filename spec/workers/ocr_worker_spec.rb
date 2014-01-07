require 'spec_helper'

describe OCRWorker do
  let(:queued_xml) {
    '<?xml version="1.0" encoding="utf-8"?>
      <response>
        <task id="TestOCR_ID" registrationTime="2013-12-20T03:31:59Z" statusChangeTime="2013-12-20T03:32:00Z" status="Queued" filesCount="1" credits="0" estimatedProcessingTime="2" />
      </response>'
  }
  let(:in_progress_xml) {
    '<?xml version="1.0" encoding="utf-8"?>
      <response>
        <task id="TestOCR_ID" registrationTime="2013-12-20T03:31:59Z" statusChangeTime="2013-12-20T03:32:01Z" status="InProgress" filesCount="1" credits="0" estimatedProcessingTime="2" />
    </response>'
  }
  let(:completed_xml) {
    '<?xml version="1.0" encoding="utf-8"?>
      <response>
        <task id="TestOCR_ID" registrationTime="2013-12-20T03:31:59Z" statusChangeTime="2013-12-20T03:32:04Z" status="Completed" filesCount="1" credits="0" resultUrl="TEST_URL" />
    </response>'
  }
  let(:error_xml_processing_failed) {
    '<?xml version="1.0" encoding="utf-8"?>
      <response>
        <task id="TestOCR_ID" registrationTime="2013-12-20T03:31:59Z" statusChangeTime="2013-12-20T03:32:01Z" status="ProcessingFailed" filesCount="1" credits="0" estimatedProcessingTime="2" />
      </response>'
  }
  let(:error_xml_not_enough_credits) {
    '<?xml version="1.0" encoding="utf-8"?>
      <response>
        <task id="TestOCR_ID" registrationTime="2013-12-20T03:31:59Z" statusChangeTime="2013-12-20T03:32:01Z" status="NotEnoughCredits" filesCount="1" credits="0" estimatedProcessingTime="2" />
      </response>'
  }
  let(:transcript) {
    'Home'
  }

  describe "Error messages" do
    it "should raise error if Tesseract is not installed and no other config is set" do
      parent = Factory(:data_file, filename: "Test_OCR.jpg", format: "image/jpeg", path: File.join(Rails.root, "samples/Test_OCR.jpg"))
      OCRWorker.stub(:create).and_return("UUID-1")
      MetadataExtractor.new.extract_metadata(parent, parent.format, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      worker = OCRWorker.new({output_id: output.id, parent_id: parent.id})
      worker.stub(:tesseract_installed?).and_return(false)
      DataFile.stub(:find).and_return(output,parent)
      Resque::Plugins::Status::Hash.stub(:get).and_return(Resque::Plugins::Status::Hash.new(status: "WORKING"))
      expect { worker.perform }.to raise_error

      output.file_processing_description.should eq("OCR ERROR: Tesseract is not installed on this server. Please contact an administrator.")
      output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      output.file_processing_status.should eq(DataFile::STATUS_ERROR)
      contents = File.open(output.path, "rb").read
      contents.should be_empty
    end

    it "Tesseract should fail if file is of the wrong MIME type" do
      # tiff is an image type not included in supported OCR types
      parent = Factory(:data_file, filename: "Test_OCR.tiff", format: "image/tiff", path: File.join(Rails.root, "samples/Test_OCR.tiff"))
      OCRWorker.stub(:create).and_return("UUID-1")
      MetadataExtractor.new.extract_metadata(parent, parent.format, true)

      parent.children.should be_empty

      # mp3 is an audio type supported in Speech Recognition only and should not be supported by OCR
      parent = Factory(:data_file, filename: "Test_SR.mp3", format: "audio/mpeg", path: File.join(Rails.root, "samples/Test_SR.mp3"))
      OCRWorker.stub(:create).and_return("UUID-2")
      MetadataExtractor.new.extract_metadata(parent, parent.format, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      worker = OCRWorker.new({output_id: output.id, parent_id: parent.id})
      DataFile.stub(:find).and_return(output, parent)
      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)
      worker.stub(:tesseract_installed?).and_return(true)
      expect { worker.perform }.to raise_error

      output.file_processing_description.should eq("OCR ERROR: Tesseract does not support #{parent.path} (#{parent.format})")
      output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      output.file_processing_status.should eq(DataFile::STATUS_ERROR)
      contents = File.open(output.path, "rb").read
      contents.should be_empty
    end

    it "should raise error if ABBYY processing failed" do
      abby_config = {
          ocr_cloud_host: "cloud.ocrsdk.com",
          ocr_cloud_id: "test",
          ocr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(abby_config)

      parent = Factory(:data_file, filename: "Test_OCR.jpg", format: "image/jpeg", path: File.join(Rails.root, "samples/Test_OCR.jpg"))
      OCRWorker.stub(:create).and_return("UUID-1")
      MetadataExtractor.new.extract_metadata(parent, parent.format, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      RestClient.stub(:post).and_return(queued_xml)
      RestClient.stub(:get).and_return(in_progress_xml, error_xml_processing_failed)

      worker = OCRWorker.new({output_id: output.id, parent_id: parent.id})
      DataFile.stub(:find).and_return(output, parent)
      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      expect { worker.perform }.to raise_error
      output.file_processing_description.should eq("OCR ERROR: The task hasn't been processed because an error occurred on ABBYY")
      output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      output.file_processing_status.should eq(DataFile::STATUS_ERROR)
      contents = File.open(output.path, "rb").read
      contents.should be_empty
    end

    it "should raise error if not enough credits on ABBYY account" do
      abby_config = {
          ocr_cloud_host: "cloud.ocrsdk.com",
          ocr_cloud_id: "test",
          ocr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(abby_config)

      parent = Factory(:data_file, filename: "Test_OCR.jpg", format: "image/jpeg", path: File.join(Rails.root, "samples/Test_OCR.jpg"))
      OCRWorker.stub(:create).and_return("UUID-1")
      MetadataExtractor.new.extract_metadata(parent, parent.format, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      RestClient.stub(:post).and_return(queued_xml)
      RestClient.stub(:get).and_return(in_progress_xml, error_xml_not_enough_credits)

      worker = OCRWorker.new({output_id: output.id, parent_id: parent.id})
      DataFile.stub(:find).and_return(output, parent)
      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      expect { worker.perform }.to raise_error
      output.file_processing_description.should eq("OCR ERROR: You don't have enough money on your account to process the task")
      output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      output.file_processing_status.should eq(DataFile::STATUS_ERROR)
      contents = File.open(output.path, "rb").read
      contents.should be_empty
    end

    it "should raise error if RestClient failed" do
      abby_config = {
          ocr_cloud_host: "cloud.ocrsdk.com",
          ocr_cloud_id: "test",
          ocr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(abby_config)

      parent = Factory(:data_file, filename: "Test_OCR.jpg", format: "image/jpeg", path: File.join(Rails.root, "samples/Test_OCR.jpg"))
      OCRWorker.stub(:create).and_return("UUID-1")
      MetadataExtractor.new.extract_metadata(parent, parent.format, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      net_http_res = double('net http response', :code => 500)
      response = RestClient::Response.create('abc', net_http_res, {})
      RestClient.stub(:post) { response.return! }
      RestClient.should_receive(:post)

      worker = OCRWorker.new({output_id: output.id, parent_id: parent.id})
      DataFile.stub(:find).and_return(output, parent)
      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      expect { worker.perform }.to raise_error
      output.file_processing_description[/^OCR ERROR: 500 Internal Server Error\. Please contact an administrator.$/].should_not be_nil
      output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      output.file_processing_status.should eq(DataFile::STATUS_ERROR)
      contents = File.open(output.path, "rb").read
      contents.should be_empty
    end

    it "should raise error if host does not exist" do
      abby_config = {
          ocr_cloud_host: "host name is wrong",
          ocr_cloud_id: "test",
          ocr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(abby_config)

      parent = Factory(:data_file, filename: "Test_OCR.jpg", format: "image/jpeg", path: File.join(Rails.root, "samples/Test_OCR.jpg"))
      OCRWorker.stub(:create).and_return("UUID-1")
      MetadataExtractor.new.extract_metadata(parent, parent.format, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      worker = OCRWorker.new({output_id: output.id, parent_id: parent.id})
      DataFile.stub(:find).and_return(output, parent)
      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      expect { worker.perform }.to raise_error
      output.file_processing_description.should eq("OCR ERROR: bad URI(is not URI?): http://test:test@host name is wrong/processImage?language=English&exportFormat=txt")
      output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      output.file_processing_status.should eq(DataFile::STATUS_ERROR)
      contents = File.open(output.path, "rb").read
      contents.should be_empty
    end
  end

  describe "successful conversions" do
    it "should be successful if Tesseract is installed, even if no config is set" do
      parent = Factory(:data_file, filename: "Test_OCR.jpg", format: "image/jpeg", path: File.join(Rails.root, "samples/Test_OCR.jpg"))
      OCRWorker.stub(:create).and_return("UUID-1")
      MetadataExtractor.new.extract_metadata(parent, parent.format, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      worker = OCRWorker.new({output_id: output.id, parent_id: parent.id})
      DataFile.stub(:find).and_return(output,parent)
      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)
      worker.stub(:tesseract_installed?).and_return(true)
      expect { worker.perform }.not_to raise_error

      tesseract_version = %x(tesseract -v 2>&1).split("\n")[0].camelize
      output.file_processing_description.should eq("This file was automatically generated by OCR (#{tesseract_version}).\nSource file name: #{parent.filename}\nSource file id: #{output.id}")
      output.transfer_status.should eq(DataFile::RESQUE_COMPLETE)
      output.file_processing_status.should eq "PROCESSED"
      contents = File.open(output.path, "rb").read
      contents.should_not be_empty
      contents.strip.should eq transcript
    end

    it "should be successful with correct ABBYY settings" do
      abby_config = {
          ocr_cloud_host: "cloud.ocrsdk.com",
          ocr_cloud_id: "test",
          ocr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(abby_config)

      parent = Factory(:data_file, filename: "Test_OCR.jpg", format: "image/jpeg", path: File.join(Rails.root, "samples/Test_OCR.jpg"))
      OCRWorker.stub(:create).and_return("UUID-1")
      MetadataExtractor.new.extract_metadata(parent, parent.format, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      RestClient.stub(:post).and_return(queued_xml)
      RestClient.should_receive(:post).once
      RestClient.stub(:get).and_return(in_progress_xml, completed_xml, transcript)

      RestClient.should_receive(:get).with("http://test:test@cloud.ocrsdk.com/getTaskStatus?taskid=TestOCR_ID").twice
      RestClient.should_receive(:get).with("TEST_URL")

      worker = OCRWorker.new({output_id: output.id, parent_id: parent.id})
      DataFile.stub(:find).and_return(output, parent)
      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      expect { worker.perform }.not_to raise_error

      output.file_processing_description.should eq("This file was automatically generated by OCR (ABBYY - #{abby_config[:ocr_cloud_host]}).\nSource file name: #{parent.filename}\nSource file id: #{output.id}")
      output.transfer_status.should eq(DataFile::RESQUE_COMPLETE)
      output.file_processing_status.should eq("PROCESSED")
      contents = File.open(output.path, "rb").read
      contents.should_not be_empty
      contents.strip.should eq transcript
    end
  end
end
