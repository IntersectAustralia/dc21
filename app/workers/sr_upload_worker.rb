#!/usr/bin/ruby -w

class SRUploadWorker
  include Resque::Plugins::Status

  @queue = :sr_queue

  def perform
    output_file = DataFile.find(options['output_id'])
    parent = DataFile.find(options['parent_id'])

    @config = SystemConfiguration.instance
    begin
      if [@config.sr_cloud_host, @config.sr_cloud_id, @config.sr_cloud_token].all?(&:present?)

        job = Resque::Plugins::Status::Hash.get(output_file.uuid)
        output_file.transfer_status = job.status.to_s.upcase

        output_file.save

        url = "https://#{CGI.escape(@config.sr_cloud_id)}:#{CGI.escape(@config.sr_cloud_token)}@#{@config.sr_cloud_host}/REST"

        require "rest_client"

        require "rexml/document"

        def output_response_error(e)
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
          raise "#{e.message}. Please contact an administrator."
        end

        # Upload the file
        Rails.logger.info "Uploading file.."
        begin
          Rails.logger.info url
          # Get media id from response xml to check task status later
          upload_xml = REXML::Document.new(RestClient.post("#{url}/media", :media => File.new(parent.path, 'rb')))
          Rails.logger.info upload_xml
          media_id = upload_xml.elements['mediaItem/id'].text

          Rails.logger.info REXML::Document.new(RestClient.post("#{url}/media/#{media_id}/transcribe", {}))
          output_file.file_processing_description = "#{parent.filename} has been uploaded to Koemei and is being transcribed.\n" <<
          "Koemei Media ID: #{media_id}\n"
          output_file.save

          Resque.enqueue_in(15.minutes, SRPollWorker, {'output_id' => output_file.id, 'parent_id' => parent.id, 'media_id' => media_id})

        rescue RestClient::ExceptionWithResponse => e
          output_response_error(e)
        end
      else
        raise "Koemei account details have not been completely specified."
      end

    rescue Exception => e
      output_file.mark_as_failed
      # Catch exception, set transfer status and rethrow so we can see what went wrong in the overview page
      output_file.file_processing_description = "SR ERROR: #{e.message}"
      output_file.file_processing_status = DataFile::STATUS_ERROR
      output_file.save
      Rails.logger.info "SR ERROR: #{e.message}"
      raise e
    end
  end

end




