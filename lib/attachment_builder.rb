class AttachmentBuilder

  def initialize(post_params, files_root, current_user, file_type_determiner, metadata_extractor)
    @post_params = post_params
    @files_root = files_root
    @current_user = current_user
    @file_type_determiner = file_type_determiner
    @metadata_extractor = metadata_extractor
  end

  def verify_from_filenames
    keys_to_filenames.reduce({}) do |result, key_and_filename|
      key, filename = key_and_filename

      #{"collections.json":{"status":"abort","message":"This file already exists."}}
      if DataFile.where(:filename => filename).empty?
        result.merge filename => {:status => "proceed", :message => ""}
      else
        result.merge filename => {:status => "abort", :message => "This file already exists."}
      end
    end
  end

  def build
    keys_to_filenames.reduce({}) do |result, key_and_filename|
      key, filename = key_and_filename
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

    station_name = nil
    table_name = nil
    mismatched_overlap = data_file.mismatched_overlap(station_name, table_name)
    safe_overlap = data_file.safe_overlap(station_name, table_name)

    if mismatched_overlap.any?
      filenames = data_file.mismatched_overlap.select(:filename).map(&:filename).join ','
      message = "overlaps with #{filenames}"
      {:status => "failure", :message => message}
    elsif safe_overlap.any?
      data_file.save!
      safe_overlap.destroy
      filenames = data_file.safe_overlap.select(:filename).map(&:filename).join ','
      {:status => "success", :message => "overwrote #{filenames}"}
    elsif data_file.save
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
