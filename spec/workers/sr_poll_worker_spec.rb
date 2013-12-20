require 'spec_helper'

describe SRPollWorker do


  let(:no_transcript){
    '<mediaItem>
      <link rel="http://www.w3.org/2005/Atom" href="https://www.koemei.com/REST/media/TestKoemeiMediaId"/>
      <id>TestKoemeiMediaId</id>
      <title>Title of the media</title>
      <description>Description of the media</description>
      <time>00:01:48</time>
      <date>Fri 27. Apr 2012</date>
      <fileName>Test_SR.mp3</fileName>
      <sampleRate>44100</sampleRate>
      <bitDepth>16</bitDepth>
      <channels>2</channels>
      <size>246</size>
      <language>en</language>
    </mediaItem>'
  }

  let(:with_transcript){
    '<mediaItem>
      <link rel="http://www.w3.org/2005/Atom" href="https://www.koemei.com/REST/media/TestKoemeiMediaId"/>
      <id>TestKoemeiMediaId</id>
      <title>Title of the media</title>
      <description>Description of the media</description>
      <time>00:01:48</time>
      <date>Fri 27. Apr 2012</date>
      <fileName>Test_SR.mp3</fileName>
      <sampleRate>44100</sampleRate>
      <bitDepth>16</bitDepth>
      <channels>2</channels>
      <size>246</size>
      <language>en</language>
      <currentTranscript>
        <id>TestKoemeiTranscriptId</id>
        <link rel="related" href="https://www.koemei.com/REST/transcripts/TestKoemeiTranscriptId" title="Current transcript"/>
      </currentTranscript>
    </mediaItem>'
  }
  let(:transcript){
    'This is a test script.'
  }

  before(:each) {
    @parent = Factory(:data_file, filename: "abc.mp3", format: "audio/mpeg", path: File.join(Rails.root, "samples/Test_SR.mp3"))
    SRPollWorker.stub(:create).and_return("UUID-1")
    MetadataExtractor.new.extract_metadata(@parent, @parent.format, true)
    @output = @parent.children.first

    #This assumes successful upload
    @output.file_processing_description = "TestSR.mp3 has been uploaded to Koemei and is being transcribed.\nKoemei Media ID: TestKoemeiMediaId\n"
    @output.transfer_status = DataFile::RESQUE_WORKING
    @output.file_processing_status = "PROCESSED"
    @output.save

    @options = {'output_id' =>  @output.id, 'parent_id' =>  @parent.id, 'media_id' => "TestKoemeiMediaId"}

    SRPollWorker.any_instance.stub(:options).and_return(@options)
  }

  describe "Error messages" do
    it "should raise error if Koemei details are not supplied" do
      #should not enqueue anything
      Resque.should_not_receive(:enqueue_in)
      RestClient.should_not_receive(:get)
      expect { SRPollWorker.new(@options).perform }.to raise_error
      ActionMailer::Base.deliveries.empty?.should eq(true)

      @output.reload
      @output.file_processing_description.should eq("SR ERROR: Koemei account details have not been completely specified.")
      @output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      @output.file_processing_status.should eq(DataFile::STATUS_ERROR)
    end

    it "should raise error if host does not exist" do
      koemei_config = {
        sr_cloud_host: "host name is wrong",
        sr_cloud_id: "test",
        sr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(koemei_config)

      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      #should not enqueue anything
      Resque.should_not_receive(:enqueue_in)

      expect { SRPollWorker.new(@options).perform }.to raise_error
      ActionMailer::Base.deliveries.empty?.should eq(true)

      @output.reload
      @output.file_processing_description.should eq("SR ERROR: bad URI(is not URI?): https://test:test@host name is wrong/REST/media/TestKoemeiMediaId")
      @output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      @output.file_processing_status.should eq(DataFile::STATUS_ERROR)
    end

    it "should raise error if the service returns an error code" do
      koemei_config = {
        sr_cloud_host: "www.test.com",
        sr_cloud_id: "test",
        sr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(koemei_config)

      resque_job = Resque::Plugins::Status::Hash.new()
      resque_job.status = "WORKING"
      Resque::Plugins::Status::Hash.stub(:get).and_return(resque_job)

      net_http_res = double('net http response', :code => 500)
      response = RestClient::Response.create('abc', net_http_res, {})
      RestClient.stub(:get) { response.return! }

      #should not enqueue anything
      Resque.should_not_receive(:enqueue_in)

      expect { SRPollWorker.new(@options).perform }.to raise_error
      ActionMailer::Base.deliveries.empty?.should eq(true)

      @output.reload
      @output.file_processing_description[/^SR ERROR: 500 Internal Server Error\. Please contact an administrator.$/].should_not be_nil
      @output.transfer_status.should eq(DataFile::RESQUE_FAILED)
      @output.file_processing_status.should eq(DataFile::STATUS_ERROR)
    end
  end

  #check Koemei Media ID is saved in output file
  describe "Successful polling with no detected transcript" do
      it "should create another poller in 5 minutes" do
      koemei_config = {
        sr_cloud_host: "www.test.com",
        sr_cloud_id: "test",
        sr_cloud_token: "test"
      }

      SystemConfiguration.instance.update_attributes(koemei_config)

      RestClient.stub(:get).and_return(no_transcript)
      RestClient.should_receive(:get).once

      Resque.stub(:enqueue_in).and_return(true)
      # check that a poll worker is enqueued with the correct parameters
      Resque.should_receive(:enqueue_in).with(5.minutes, SRPollWorker, @options)

      SRPollWorker.new(@options).perform

      ActionMailer::Base.deliveries.empty?.should eq(true)

      @output.reload
      #output file should remain the same
      @output.file_processing_description.should eq("TestSR.mp3 has been uploaded to Koemei and is being transcribed.\nKoemei Media ID: TestKoemeiMediaId\n")
      @output.transfer_status.should eq(DataFile::RESQUE_WORKING)
      @output.file_processing_status.should eq("PROCESSED")
      contents = File.open(@output.path, "rb").read
      contents.should eq("")
    end
  end

  #check Koemei Media ID is saved in output file
  describe "Successful polling with detected transcript" do
      it "should update data file, update file content and email user" do
        koemei_config = {
          sr_cloud_host: "www.test.com",
          sr_cloud_id: "test",
          sr_cloud_token: "test"
        }

        SystemConfiguration.instance.update_attributes(koemei_config)

        RestClient.stub(:get).and_return(with_transcript,transcript)

        # check that poll worker is not created since the process is complete
        Resque.should_not_receive(:enqueue_in).with(15.minutes, SRPollWorker, @options)
        SRPollWorker.new(@options).perform

        # check that the email has been queued for sending
        ActionMailer::Base.deliveries.empty?.should eq(false)
        email = ActionMailer::Base.deliveries.last
        email.subject.should eq("HIEv - Processing completed")
        email.to.should eq([@parent.created_by.email])
        email.body.should eq(<<-eos
<p>Hello Fred Bloggs,</p>
<p>The processing of file abc.mp3.txt is now complete.</p>
<p>You can view the file at http://localhost:3000/data_files/#{@output.id}</p>
<p>
This file was automatically generated by SR (Koemei).
<br>
Source file name: abc.mp3
<br>
Source file id: #{@parent.id}
<br>
Length: 4 minutes 6 seconds
<br>
Koemei Media ID: TestKoemeiMediaId
<br>
</p>
eos
)

        @output.reload
        @output.file_processing_description.should eq("This file was automatically generated by SR (Koemei).\nSource file name: #{@parent.filename}\nSource file id: #{@parent.id}\nLength: 4 minutes 6 seconds\nKoemei Media ID: TestKoemeiMediaId\n")
        @output.transfer_status.should eq(DataFile::RESQUE_COMPLETE)
        @output.file_processing_status.should eq("PROCESSED")
        contents = File.open(@output.path, "rb").read
        contents.should eq(transcript)

      end
    end

end
