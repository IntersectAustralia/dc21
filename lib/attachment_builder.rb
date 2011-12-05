class AttachmentBuilder

  def initialize(post_params, files_root, current_user)
    @post_params = post_params
    @files_root = files_root
    @current_user = current_user
  end

  def build
    dest_dir = @files_root
    json_string = @post_params[:dirStruct]
    file_list = ActiveSupport::JSON.decode(json_string)
    Rails.logger.debug("AttachmentBuilder.build file_list=#{file_list.inspect}")

    # Turn tree into some attributes ready to build attachments
    candidates = []
    file_list.each do |file_tree|
      attrs = process_file_or_folder(dest_dir, file_tree)
      candidates << attrs
    end

    process_attachments(candidates, dest_dir)
  end

  def process_attachments(candidates, dest_dir)
    result = {}

    if !Dir.exist? dest_dir
      Rails.logger.debug("Creating folder #{dest_dir}")
      FileUtils.mkdir_p(dest_dir)
    end

    create_attachments(candidates, dest_dir, result)
  end

  def create_attachments(new_attachments, dest_dir, result)
    new_attachments.each do |attributes|
      Rails.logger.info("Processing: #{attributes}")

      attachment = DataFile.create(attributes.merge({:created_by => @current_user}))
      if attachment.save
        result[attributes[:filename]] = {:status => "success", :message => ""}
      else
        Rails.logger.info("Failed: #{attachment.errors}")
        result[attributes[:filename]] = {:status => "failure", :message => attachment.errors}
      end
    end

    result
  end

  def write_files(dest_dir, file_tree)
    filename = get_filename(file_tree)
    create_all_files(file_tree, dest_dir)
    filename
  end

  def process_file_or_folder(dest_dir, file_tree)
    filename = write_files(dest_dir, file_tree)
    format = 'file'
    path = File.join(dest_dir, filename)

    {:filename => filename,
     :path => path,
     :format => format}
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

  def add_metadata(attachment)
    # do nothing right now
  end

end
