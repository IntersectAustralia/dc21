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
    dest_dir = @files_root

    file_list = gather_file_list
    candidates = []

    file_list.each do |file_tree|
      attrs = process_file_or_folder(dest_dir, file_tree)
      candidates << attrs
    end

    process_files(candidates, dest_dir)
  end

  private

  # Turn tree into some attributes ready to build files
  def gather_file_list

    json_string = @post_params[:dirStruct]
    file_list = ActiveSupport::JSON.decode(json_string)
    Rails.logger.debug("AttachmentBuilder.gather_file_list file_list=#{file_list.inspect}")

    file_list
  end

  def process_files(candidates, dest_dir)
    result = {}

    if !Dir.exist? dest_dir
      Rails.logger.debug("Creating folder #{dest_dir}")
      FileUtils.mkdir_p(dest_dir)
    end

    create_data_files(candidates, dest_dir, result)
  end

  def create_data_files(new_files, dest_dir, result)
    new_files.each do |attributes|
      Rails.logger.info("Processing: #{attributes}")

      data_file = DataFile.create(attributes.merge({:created_by => @current_user}))
      if data_file.save
        result[attributes[:filename]] = {:status => "success", :message => ""}
        process_metadata(data_file)
      else
        Rails.logger.info("Failed: #{data_file.errors}")
        result[attributes[:filename]] = {:status => "failure", :message => data_file.errors}
      end
    end
    result
  end

  def process_metadata(data_file)
    known, type = @file_type_determiner.identify_file(data_file)
    if known
      @metadata_extractor.extract_metadata(data_file, type)
      data_file.format = type
      data_file.save
    end
  end

  def write_files(dest_dir, file_tree)
    filename = get_filename(file_tree)
    create_all_files(file_tree, dest_dir)
    filename
  end

  def process_file_or_folder(dest_dir, file_tree)
    filename = write_files(dest_dir, file_tree)
    path = File.join(dest_dir, filename)

    {:filename => filename,
     :path => path}
  end

  def get_filename(file_tree)
    file_key = file_tree.keys.find { |key| key.starts_with? "file_" }
    file_tree[file_key]
  end

  def create_all_files(file_tree, dest_dir)
    file_list = file_tree.find_all { |type, val| type.starts_with? "file_" }
    file_list.each do |key, path|
      file = @post_params[key.to_sym]
      upload_path = File.join(dest_dir, path.gsub(/\\+/, "/"))
      if !Dir.exist? dest_dir
        FileUtils.mkdir_p(dest_dir)
      end
      FileUtils.cp_r(file.path, upload_path)
    end
  end

end
