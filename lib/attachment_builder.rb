class AttachmentBuilder

  def initialize(files_root, current_user, file_type_determiner, metadata_extractor)
    @files_root = files_root
    @current_user = current_user
    @file_type_determiner = file_type_determiner
    @metadata_extractor = metadata_extractor
  end

  def build(file, experiment_id, type)
    path = store_file(file)
    create_data_file(path, file.original_filename, experiment_id, type)
  end

  private

  def create_data_file(path, filename, experiment_id, type)
    Rails.logger.info("Processing: #{path} - #{filename}")

    data_file = DataFile.new(:path => path, :filename => filename, :created_by => @current_user, :file_processing_status => type, :experiment_id => experiment_id)
    data_file.messages = ["File uploaded successfully"]

    format = @file_type_determiner.identify_file(data_file)
    data_file.format = format

    data_file.save!
    @metadata_extractor.extract_metadata(data_file, format) if format
    data_file
  end

  def store_file(file)
    filename = file.original_filename
    store_path = File.join(@files_root, filename)

    FileUtils.cp(file.path, store_path)

    store_path
  end

end
