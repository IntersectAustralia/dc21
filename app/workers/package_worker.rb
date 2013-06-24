#!/usr/bin/ruby -w
require 'bagit'
require 'digest/md5'

class PackageWorker
  include Resque::Plugins::Status

  @queue = :package_queue

  def perform
    begin
      @total_processed = 0

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

    rescue Exception => e
      # Catch exception, set transfer status and rethrow so we can see what went wrong in the overview page
      pkg.mark_as_failed
      raise e
    end
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
    digest_filename = Digest::MD5.hexdigest(pkg.filename)
    path = "#{File.join(APP_CONFIG['files_root'], "#{digest_filename}_tmp")}"
    Dir.mkdir path

    zip_path = "#{File.join(APP_CONFIG['files_root'], "#{digest_filename}.tmp")}"
    zip_file = File.new(zip_path, 'a+')

    begin
      bag = BagIt::Bag.new path

      readme_path = File.join(bag.data_dir, "README.html")

      data_files = DataFile.find(ids)
      total_filesize = 0
      data_files.each do |data_file|
        temp_path = File.join(bag.data_dir, data_file.filename)
        total_filesize += File.size(data_file.path)
        FileUtils.cp data_file.path, temp_path
      end

      readme_html = MetadataWriter.generate_metadata_for(data_files, pkg)
      File.open(readme_path, 'w+') { |f| f.write(readme_html) }

      bag.manifest!

      build_zip(zip_file, Dir["#{path}/*"], total_filesize)
      block.yield(zip_file)
    rescue Exception => e
      raise e
    ensure
      zip_file.close
      FileUtils.rm_rf path
      FileUtils.rm zip_path
    end
  end

  def build_zip(zip_file, file_paths, total_filesize)
    Zip::ZipOutputStream.open(zip_file.path) do |zos|
      file_paths.each do |path|
        if File.directory?(path)
          dir_name = File.basename(path)
          all_files = Dir.foreach(path).reject { |f| f.starts_with?(".") }
          all_files.each do |file|
            zos.put_next_entry("#{dir_name}/#{file}")
            file = File.open(File.join(path, file), 'rb')

            write_to_zip(zos, file, total_filesize)
          end
        else
          # Single file processing
          zos.put_next_entry(File.basename(path))
          file = File.open(path, 'rb')

          write_to_zip(zos, file, total_filesize)
        end
      end
    end
  end

  def write_to_zip(zos, file, total_filesize)
    chunk_size = 1024 * 1024
    each_chunk(file, chunk_size) do |chunk|
      @total_processed = @total_processed + chunk_size
      zos << chunk
      at(@total_processed, total_filesize, "At #{@total_processed} of #{total_filesize} bytes")
    end
  end

  def each_chunk(file, chunk_size=1024)
    yield file.read(chunk_size) until file.eof?
  end

end