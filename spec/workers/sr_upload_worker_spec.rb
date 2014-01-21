require 'spec_helper'

describe SRUploadWorker do
  let(:user) { Factory(:user) }

  describe "Error messages" do
    it "should raise error if Koemei details are not supplied" do
      parent = Factory(:data_file, filename: "abc.mp3", format: "audio/mpeg", path: File.join(Rails.root, "samples/Test_SR.mp3"))

      SRUploadWorker.stub(:create).and_return("UUID-1")

      # forces metadata extraction
      MetadataExtractor.new.extract_metadata(parent, parent.format, user, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      worker = SRUploadWorker.new({output_id: output.id, parent_id: parent.id})

      DataFile.stub(:find).and_return(output,parent)

      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      #should not enqueue anything
      Resque.should_not_receive(:enqueue_in)
      expect { worker.perform }.to raise_error

      output.file_processing_description.should eq("SR ERROR: Koemei account details have not been completely specified.")
      output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      output.file_processing_status.should eq(DataFile::STATUS_ERROR)
    end

    it "should raise error if file does not exist" do
      koemei_config = {
        sr_cloud_host: "www.test.com",
        sr_cloud_id: "test",
        sr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(koemei_config)

      parent = Factory(:data_file, filename: "abc.mp3", format: "audio/mpeg", path: "this doesn't exist")

      SRUploadWorker.stub(:create).and_return("UUID-1")

      # forces metadata extraction
      MetadataExtractor.new.extract_metadata(parent, parent.format, user, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      worker = SRUploadWorker.new({output_id: output.id, parent_id: parent.id})

      DataFile.stub(:find).and_return(output,parent)

      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      #should not enqueue anything
      Resque.should_not_receive(:enqueue_in)

      expect { worker.perform }.to raise_error

      output.file_processing_description.should eq("SR ERROR: No such file or directory - this doesn't exist")
      output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      output.file_processing_status.should eq(DataFile::STATUS_ERROR)
    end

    it "should raise error if host does not exist" do
      koemei_config = {
        sr_cloud_host: "host name is wrong",
        sr_cloud_id: "test",
        sr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(koemei_config)

      parent = Factory(:data_file, filename: "abc.mp3", format: "audio/mpeg", path: File.join(Rails.root, "samples/Test_SR.mp3"))

      SRUploadWorker.stub(:create).and_return("UUID-1")

      # forces metadata extraction
      MetadataExtractor.new.extract_metadata(parent, parent.format, user, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      worker = SRUploadWorker.new({output_id: output.id, parent_id: parent.id})

      DataFile.stub(:find).and_return(output,parent)

      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      #should not enqueue anything
      Resque.should_not_receive(:enqueue_in)

      expect { worker.perform }.to raise_error

      output.file_processing_description.should eq("SR ERROR: bad URI(is not URI?): https://test:test@host name is wrong/REST/media")
      output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      output.file_processing_status.should eq(DataFile::STATUS_ERROR)
    end

    it "should raise error if the service returns an error code" do
      koemei_config = {
        sr_cloud_host: "www.test.com",
        sr_cloud_id: "test",
        sr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(koemei_config)

      parent = Factory(:data_file, filename: "abc.mp3", format: "audio/mpeg", path: File.join(Rails.root, "samples/Test_SR.mp3"))

      SRUploadWorker.stub(:create).and_return("UUID-1")

      # forces metadata extraction
      MetadataExtractor.new.extract_metadata(parent, parent.format, user, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      worker = SRUploadWorker.new({output_id: output.id, parent_id: parent.id})

      DataFile.stub(:find).and_return(output,parent)

      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      net_http_res = double('net http response', :code => 500)
      response = RestClient::Response.create('abc', net_http_res, {})
      RestClient.stub(:post) { response.return!}

      #should not enqueue anything
      Resque.should_not_receive(:enqueue_in)

      expect { worker.perform }.to raise_error

      output.file_processing_description[/^SR ERROR: 500 Internal Server Error\. Please contact an administrator.$/].should_not be_nil
      output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      output.file_processing_status.should eq(DataFile::STATUS_ERROR)
    end
  end

  #check Koemei Media ID is saved in output file
  describe "Successful upload adds Koemei Media ID" do
    it "should save media ID in output file description" do
      koemei_config = {
        sr_cloud_host: "www.test.com",
        sr_cloud_id: "test",
        sr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(koemei_config)

      parent = Factory(:data_file, filename: "TestSR.mp3", format: "audio/mpeg", path: File.join(Rails.root, "samples/Test_SR.mp3"))

      SRUploadWorker.stub(:create).and_return("UUID-1")
      SRUploadWorker.should_receive(:create)

      # forces metadata extraction, this should create a child
      MetadataExtractor.new.extract_metadata(parent, parent.format, user, true)

      output = parent.children.first
      output.should_not be_nil
      output.filename.should eq("#{parent.filename}.txt")
      output.format.should eq("text/plain")
      output.file_processing_status.should eq("PROCESSED")
      output.experiment_id.should eq(parent.experiment_id)

      upload_response = '<mediaItem><id>TestKoemeiMediaId</id></mediaItem>'
      transcribe_response = '<status xmlns:atom="http://www.w3.org/2005/Atom">
    <state>PENDING</state>
    <progress>0</progress>
    <atom:link href="https://www.test.com/REST/media/TestKoemeiMediaId/transcribe/TESTPROCESSID" rel="self"></atom:link>
</status>'

      RestClient.stub(:post).and_return(upload_response,transcribe_response)

      worker = SRUploadWorker.new({output_id: output.id, parent_id: parent.id})

      DataFile.stub(:find).and_return(output, parent)
      # this test doesn't actually use Resque, so we need to stub the job object
      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)
      Resque.stub(:enqueue_in).and_return(true)
      # check that a poll worker is enqueued with the correct parameters
      Resque.should_receive(:enqueue_in).with(15.minutes, SRPollWorker, {'output_id' => output.id, 'parent_id' => parent.id, 'media_id' => "TestKoemeiMediaId"})

      worker.perform

      output.file_processing_description.should eq("TestSR.mp3 has been uploaded to Koemei and is being transcribed.\nKoemei Media ID: TestKoemeiMediaId\n")
      output.transfer_status.should eq(DataFile::RESQUE_WORKING)
      output.file_processing_status.should eq("PROCESSED")
    end
  end

end
