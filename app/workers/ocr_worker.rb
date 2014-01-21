#!/usr/bin/ruby -w


class OCRWorker
  include Resque::Plugins::Status

  @queue = :ocr_queue

  def perform
    output_file = DataFile.find(options['output_id'])
    parent = DataFile.find(options['parent_id'])

    @config = SystemConfiguration.instance
    begin
      job = Resque::Plugins::Status::Hash.get(output_file.uuid)
      output_file.transfer_status = job.status.to_s.upcase

      output_file.save

      if [@config.ocr_cloud_host, @config.ocr_cloud_id, @config.ocr_cloud_token].all?(&:present?)
        url = "http://#{CGI.escape(@config.ocr_cloud_id)}:#{CGI.escape(@config.ocr_cloud_token)}@#{@config.ocr_cloud_host}"

        require "rest_client"

        require "rexml/document"

        # Routine for OCR SDK error output
        def output_response_error(e)
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
          # Parse response xml (see http://ocrsdk.com/documentation/specifications/status-codes)
          xml_data = REXML::Document.new(e.response)
          if xml_data.elements["error/message"]
            raise "#{xml_data.elements["error/message"].text}"
          else
            raise "#{e.message}. Please contact an administrator."
          end
        end

        # Upload and process the image (see http://ocrsdk.com/documentation/apireference/processImage)
        Rails.logger.info "Uploading file.."
        begin
          response = RestClient.post("#{url}/processImage?language=English&exportFormat=txt", :upload => {
            :file => File.new(parent.path, 'rb')
          })

        rescue RestClient::ExceptionWithResponse => e
          # Show processImage errors
          output_response_error(e)
        else
          # Get task id from response xml to check task status later
          Rails.logger.info response
          xml_data = REXML::Document.new(response)
          task_id = xml_data.elements["response/task"].attributes["id"]
          Rails.logger.info (xml_data)
        end

        # Get task information in a loop until task processing finishes
        Rails.logger.info "Processing image.."
        begin
          # Make a small delay
          sleep(0.5)

          # Call the getTaskStatus function (see http://ocrsdk.com/documentation/apireference/getTaskStatus)
          response = RestClient.get("#{url}/getTaskStatus?taskid=#{task_id}")
        rescue RestClient::ExceptionWithResponse => e
          # Show getTaskStatus errors
          output_response_error(e.response)
        else
          # Get the task status from response xml
          xml_data = REXML::Document.new(response)
          Rails.logger.debug xml_data
          task_status = xml_data.elements["response/task"].attributes["status"]

          # Check if there were errors ..
          raise "The task hasn't been processed because an error occurred on ABBYY" if task_status == "ProcessingFailed"

          # .. or you don't have enough credits (see http://ocrsdk.com/documentation/specifications/task-statuses for other statuses)
          raise "You don't have enough money on your account to process the task" if task_status == "NotEnoughCredits"
        end until task_status == "Completed"

        # Get the result download link
        download_url = xml_data.elements["response/task"].attributes["resultUrl"]

        # Download the result
        Rails.logger.info "Downloading result.."
        recognized_text = RestClient.get(download_url)
        Rails.logger.debug recognized_text
        File.open(output_file.path, "w:UTF-8") {|f| f.write(recognized_text.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => ""})) }
        ocr_type = "ABBYY - #{@config.ocr_cloud_host}"
      else
        if tesseract_installed?
          tmp = Tempfile.new('dc21_ocr')
          if run_tesseract(parent,tmp)
            system *%W(mv #{tmp.path}.txt #{output_file.path})
            ocr_type = %x(tesseract -v 2>&1).split("\n")[0].camelize
          else
            raise "Tesseract does not support #{parent.path} (#{parent.format})"
          end
        else
          raise "Tesseract is not installed on this server. Please contact an administrator."
        end

      end

      output_file.file_processing_description = "This file was automatically generated by OCR (#{ocr_type}).\n" <<
      "Source file name: #{parent.filename}\n" <<
      "Source file id: #{parent.id}"
      output_file.file_size = File.size(output_file.path)
      output_file.save

      output_file.mark_as_complete
      Notifier.notify_user_of_completed_processing(output_file).deliver

    rescue Exception => e
      output_file.mark_as_failed
      # Catch exception, set transfer status and rethrow so we can see what went wrong in the overview page
      output_file.file_processing_description = "OCR ERROR: #{e.message}"
      output_file.file_processing_status = DataFile::STATUS_ERROR
      output_file.save
      Rails.logger.info "OCR ERROR: #{e.message}"
      raise e
    end
  end

  def run_tesseract(parent, tmp)
    Rails.logger.info "Saving #{parent.path} to #{tmp.path} temporarily"
    system *%W(tesseract #{parent.path} #{tmp.path})
  end

  def tesseract_installed?
    `which tesseract`[/tesseract/].eql?("tesseract")
  end

end



