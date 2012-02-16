class AttachmentBuilder

  def initialize(post_params, files_root, current_user, file_type_determiner, metadata_extractor)
    @post_params = post_params
    @files_root = files_root
    @current_user = current_user
    @file_type_determiner = file_type_determiner
    @metadata_extractor = metadata_extractor
  end

  def verify_from_filenames
    keys_to_filenames.reduce({}) do |result, (key, filename)|
      #{"collections.json":{"status":"abort","message":"This file already exists."}}
      if DataFile.where(:filename => filename).empty?
        result.merge filename => {:status => "proceed", :message => ""}
      else
        result.merge filename => {:status => "abort", :message => "This file already exists."}
      end
    end
  end

  def build
    keys_to_filenames.reduce({}) do |result, (key, filename)|
      file = @post_params[key.to_sym]

      path = store_file(file)
      status = create_data_file(path, filename)

      result.merge(filename => status)
    end
  end

  private

  def keys_to_filenames

    json_string = @post_params[:dirStruct]
    dir_struct = ActiveSupport::JSON.decode(json_string)
    dir_struct.reduce({}) {|hash, key_to_filename| hash.merge Hash[*key_to_filename.flatten]}
  end

  def create_data_file(path, filename)
    Rails.logger.info("Processing: #{path} - #{filename}")

    data_file = DataFile.new :path => path, :filename => filename, :created_by => @current_user

    _, format = @file_type_determiner.identify_file(data_file)
    data_file.format = format

    if data_file.save
      @metadata_extractor.extract_metadata(data_file, format) if format
      {:status => "success", :message => ""}
    else
      Rails.logger.info("Failed: #{data_file.errors}")
      {:status => "failure", :message => data_file.errors}
    end
  end

  def store_file(file)
    filename = file.original_filename
    store_path = File.join(@files_root, filename)

    FileUtils.cp(file.path, store_path)

    store_path
  end

end
