require 'bagit'
class PackageWorker
  include Resque::Plugins::Status

  @queue = :package_queue

  PACKAGE_COMPLETE = 'COMPLETE'

  def perform
    package_id = options['package_id']
    data_file_ids = options['data_file_ids']
    user_id = options['user_id']

    user = User.find(user_id)
    pkg = DataFile.find(package_id)

    job = Resque::Plugins::Status::Hash.get(pkg.uuid)
    pkg.transfer_status = job.status.to_s.upcase
    pkg.save

    bagit_for_files_with_ids(data_file_ids, pkg) do |zip_file|
      attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], user, FileTypeDeterminer.new, MetadataExtractor.new)
      files = attachment_builder.build_package(pkg, zip_file)
      build_rif_cs(files, pkg, user) unless files.nil?
    end

    # Since the parent of the action can't update it
    pkg.mark_as_complete
    # Send email indicating its complete
    Notifier.notify_user_of_completed_package(pkg).deliver
  end

  private

  # Build the rif-cs and place in the unpublished_rif_cs folder, where it will stay until published in DC21
  def build_rif_cs(files, package, user)
    dir = APP_CONFIG['unpublished_rif_cs_directory']
    Dir.mkdir(dir) unless Dir.exists?(dir)
    output_location = File.join(dir, "rif-cs-#{package.id}.xml")

    file = File.new(output_location, 'w')

    options = {:root_url => Rails.application.routes.url_helpers.root_path,
               :collection_url => Rails.application.routes.url_helpers.data_file_path(package),
               :zip_url => Rails.application.routes.url_helpers.download_data_file_path(package),
               :submitter => user}
    RifCsGenerator.new(PackageRifCsWrapper.new(package, files, options), file).build_rif_cs
    file.close
  end


  def bagit_for_files_with_ids(ids, pkg, &block)
    temp_dir = Dir.mktmpdir
    zip_file = Tempfile.new("download_zip")

    begin
      bag = BagIt::Bag.new temp_dir
      readme_path = File.join(bag.data_dir, "README.html")

      data_files = DataFile.find(ids)
      data_files.each do |data_file|
        temp_path = File.join(bag.data_dir, data_file.filename)
        FileUtils.cp data_file.path, temp_path
        temp_path
      end

      readme_html = MetadataWriter.generate_metadata_for(data_files, pkg)
      File.open(readme_path, 'w+') { |f| f.write(readme_html) }

      bag.manifest!

      number_of_files = data_files.length
      build_zip(zip_file, Dir["#{temp_dir}/*"], number_of_files)
      block.yield(zip_file)
    ensure
      zip_file.close
      zip_file.unlink
      FileUtils.remove_entry_secure temp_dir
    end
  end

  def build_zip(zip_file, file_paths, number_of_files)
    Zip::ZipOutputStream.open(zip_file.path) do |zos|
      data_files_processed = 0
      file_paths.each do |path|
        if File.directory?(path)
          dir_name = File.basename(path)
          all_files = Dir.foreach(path).reject { |f| f.starts_with?(".") }
          all_files.each do |file|
            zos.put_next_entry("#{dir_name}/#{file}")
            zos << File.open(File.join(path,file), 'rb') { |file| file.read }
          end
          data_files_processed += 1
        else
          zos.put_next_entry(File.basename(path))
          zos << File.open(path, 'rb') { |file| file.read }
          data_files_processed += 1
        end
        at(data_files_processed, number_of_files, "Processed #{data_files_processed} of #{number_of_files} data files...")
      end
    end
  end

end