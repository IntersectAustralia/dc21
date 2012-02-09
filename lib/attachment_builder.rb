class AttachmentBuilder

  def initialize(post_params, files_root, current_user, file_type_determiner, metadata_extractor)
    @post_params = post_params
    @files_root = files_root
    @current_user = current_user
    @file_type_determiner = file_type_determiner
    @metadata_extractor = metadata_extractor
  end

  def verify_from_filenames
    result = {}
    filenames = gather_file_list

    filenames.each do |filename|
      #{"collections.json":{"status":"abort","message":"This file already exists."}}
      if DataFile.where(:filename => filename.values.first).empty?
        result[filename.values.first] = {:status => "proceed", :message => ""}
      else
        result[filename.values.first] = {:status => "abort", :message => "This file already exists."}
      end
    end
    result
  end

  def build
    file_list = gather_file_list

    file_list.reduce({}) do |result, file_info|
      filename, path = process_file(file_info)
      result.merge(filename => create_data_file(path, filename))
    end
  end

  private

  # Turn tree into some attributes ready to build files
  def gather_file_list

    json_string = @post_params[:dirStruct]
    file_list = ActiveSupport::JSON.decode(json_string)
    Rails.logger.debug("AttachmentBuilder.gather_file_list file_list=#{file_list.inspect}")

    file_list
  end

  def create_data_file(path, filename)
    Rails.logger.info("Processing: #{path} - #{filename}")

    data_file = DataFile.new :path => path, :filename => filename, :created_by => @current_user
    if data_file.save
      process_metadata(data_file)
      {:status => "success", :message => ""}
    else
      Rails.logger.info("Failed: #{data_file.errors}")
      {:status => "failure", :message => data_file.errors}
    end
  end

  def process_metadata(data_file)
    known, type = @file_type_determiner.identify_file(data_file)
    if known
      @metadata_extractor.extract_metadata(data_file, type)
      data_file.format = type
      data_file.save
    end
  end

  def process_file(file_info)
    file_key = file_info.keys.find { |key| key.starts_with? "file_" }
    file = @post_params[file_key.to_sym]

    filename = file.original_filename
    upload_path = File.join(@files_root, filename)

    FileUtils.cp(file.path, upload_path)

    [filename, upload_path]
  end

end
