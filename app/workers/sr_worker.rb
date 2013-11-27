#!/usr/bin/ruby -w

class SRWorker
  include Resque::Plugins::Status

  @queue = :sr_queue

  def perform
    df = DataFile.find(options['data_file_id'])
    begin

      user = df.created_by

      job = Resque::Plugins::Status::Hash.get(df.uuid)
      df.transfer_status = job.status.to_s.upcase

      df.save

      df.file_processing_description = df.file_processing_description + "\n This was processed by SRWorker at #{Time.now}."

      Dir.mktmpdir { |dir|
        type = 'PROCESSED'
        format = 'text/plain'
        description = "This file was automatically generated by speech recognition software. Source file name: #{df.filename}, source file id: #{df.id}"
        File.open("#{dir}/#{df.filename}.txt", 'w') do |f|
          f.puts ''
        end
        file = Rack::Test::UploadedFile.new("#{dir}/#{df.filename}.txt", format)
        builder = AttachmentBuilder.new(APP_CONFIG['files_root'], user, FileTypeDeterminer.new, MetadataExtractor.new)
        output_file = builder.build(file, df.experiment_id, type, description)
        output_file.mark_as_complete
      }
      df.save

      df.mark_as_complete

    rescue Exception => e
      # Catch exception, set transfer status and rethrow so we can see what went wrong in the overview page
      df.file_processing_description << "SR ERROR: #{e.message}"
      df.save
      Rails.logger.info "SR ERROR: #{e.message}"
      df.mark_as_failed
      raise e
    end
  end

end
