set :shared_file_dir, "files"
set(:shared_file_path) { File.join(shared_path, shared_file_dir) }

namespace :shared_file do

  desc <<-DESC
      Generate shared file dirs under shared/files dir and then copies files over.

      For example, given:
        set :shared_files, %w(config/database.yml db/seeds.yml)

      The following directories will be generated:
        shared/files/config/
        shared/files/db/
  DESC

  task :setup, :except => {:no_release => true} do
    if exists?(:shared_files)
      dirs = shared_files.map { |f| File.join(shared_file_path, File.dirname(f)) }
      run "#{try_sudo} mkdir -p #{dirs.join(' ')}"
      run "#{try_sudo} chmod g+w #{dirs.join(' ')}" if fetch(:group_writable, true)
      run "#{try_sudo} chown -R #{user}.#{group} #{dirs.join(' ')}"

      servers = find_servers(:no_release => false)
      servers.each do |server|
        shared_files.each do |file_path|
          top.upload(file_path, File.join(shared_file_path, file_path))
          puts "    Uploaded #{file_path} to #{File.join(shared_file_path, file_path)}".green
        end
      end

    end
  end

  after "deploy:setup", "shared_file:setup"

  desc <<-DESC
      Symlink shared files to release path.

      WARNING: It DOES NOT warn you when shared files not exist.  \
      So symlink will be created even when a shared file does not \
      exist.
  DESC
  task :create_symlink, :except => {:no_release => true} do
    (shared_files || []).each do |path|
      run "ln -nfs #{shared_file_path}/#{path} #{release_path}/#{path}"
    end
  end

  after "deploy:finalize_update", "shared_file:create_symlink"

end

after 'multistage:ensure' do
  set :shared_files, %W(
    config/environments/#{stage}.rb
    config/deploy/#{stage}.rb
    config/database.yml
    config/dc21app_config.yml
    config/shibboleth.yml
    public/favicon.ico
    public/icon_app.png
    public/icon_app_small.png
)
end
