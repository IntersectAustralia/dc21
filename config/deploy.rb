require 'rvm/capistrano'
require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'capistrano_colors'
require 'colorize'

# Extra capistrano tasks
load 'lib/intersect_capistrano_tasks'

set :application, 'dc21app'
set :stages, %w(qa staging production)
set :default_stage, "qa"

set :build_rpms, %w(gcc gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi libffi-devel openssl openssl-devel make bzip2 autoconf automake libtool bison httpd httpd-devel apr-devel apr-util-devel mod_ssl mod_xsendfile  curl curl-devel openssl openssl-devel tzdata libxml2 libxml2-devel libxslt libxslt-devel sqlite-devel git)
set :project_rpms, %w()
set :rpms_el5, %w(postgresql84-server postgresql84 postgresql84-devel)
set :rpms_el6, %w(postgresql-server postgresql postgresql-devel)

set :shared_children, shared_children + %w(log_archive)
set :bash, '/bin/bash'
set :shell, bash # This is don in two lines to allow rpm_install to refer to bash (as shell just launches cap shell)
set :rvm_ruby_string, 'ruby-1.9.2-p290@dc21app'

set :bundle_flags, "--deployment"

# Deploy using copy for now
set :scm, 'git'
#set :repository, 'ssh://git.intersect.org.au/git/dc21'
set :repository, 'git://github.com/IntersectAustralia/dc21.git'
set :deploy_via, :copy
set :copy_exclude, [".git/*"]

set(:user) { "#{defined?(user) ? user : 'devel'}" }
set(:group) { "#{defined?(group) ? group : user}" }
set(:user_home) { "/home/#{user}" }
set(:deploy_to) { "#{user_home}/#{application}" }
set(:data_dir) { "#{defined?(data_dir) ? data_dir : '/data/dc21-samples'}" }
set(:aux_data_dir) { "#{defined?(aux_data_dir) ? aux_data_dir : '/data/dc21-data'}" }
set(:rif_cs_dir) { "#{defined?(rif_cs_dir) ? rif_cs_dir : '/data/dc21-data/published_rif_cs/'}" }

default_run_options[:pty] = true

namespace :server_setup do
  task :rpm_install, :roles => :app do
    distro_rpms = el6 ? rpms_el6 : rpms_el5
    run "#{try_sudo} yum install -y #{(build_rpms + project_rpms + distro_rpms).uniq.join(' ')}", :shell => bash
  end

  task :set_proxies do
    unless proxy.nil?
      run "echo 'export http_proxy=\"#{proxy}\"' >> ~#{user}/.bashrc"
      run "echo 'export HTTP_PROXY=$http_proxy' >> ~#{user}/.bashrc"
      run "echo 'proxy=\"#{proxy}\"' >> ~#{user}/.curlrc"
      run "echo '---\nhttp-proxy: \"#{proxy}\"' >> ~#{user}/.gemrc"
    end
  end
  namespace :filesystem do
    task :dir_perms, :roles => :app do
      run "[[ -d #{data_dir} ]] || #{try_sudo} mkdir -p #{data_dir}"
      run "#{try_sudo} chown -R #{user}.#{group} #{data_dir}"
      run "[[ -d #{aux_data_dir} ]] || #{try_sudo} mkdir -p #{aux_data_dir}"
      run "#{try_sudo} chown -R #{user}.#{group} #{aux_data_dir}"
      run "[[ -d #{rif_cs_dir} ]] || #{try_sudo} mkdir -p #{rif_cs_dir}"
      run "#{try_sudo} chown -R #{user}.#{group} #{rif_cs_dir}"
      run "[[ -d #{deploy_to} ]] || #{try_sudo} mkdir #{deploy_to}"
      run "#{try_sudo} chown -R #{user}.#{group} #{deploy_to}"
      run "#{try_sudo} chmod 0711 #{user_home}"
    end

    task :mkdir_db_dumps, :roles => :app do
      run "#{try_sudo} mkdir -p #{shared_path}/db_dumps"
      run "#{try_sudo} chown -R #{user}.#{group} #{shared_path}/db_dumps"
    end
  end
  namespace :rvm do
    task :trust_rvmrc do
      run "rvm rvmrc trust #{release_path}"
    end
  end
  task :gem_install, :roles => :app do
    run "gem install bundler passenger"
  end
  task :passenger, :roles => :app do
    run "passenger-install-apache2-module -a"
  end
  namespace :config do
    task :apache do
      run "cd #{release_path}/config/httpd && ruby passenger_setup.rb \"#{rvm_ruby_string}\" \"#{current_path}\" \"#{web_server}\" \"#{stage}\""
      src = "#{release_path}/config/httpd/apache_insertion.conf"
      dest = "/etc/httpd/conf.d/rails_#{application}.conf"
      run "cmp -s #{src} #{dest} > /dev/null; [ $? -ne 0 ] && #{try_sudo} cp #{src} #{dest} && #{try_sudo} /sbin/service httpd graceful; /bin/true"
    end
  end
  namespace :logging do
    task :rotation, :roles => :app do
      src = "#{release_path}/config/#{application}.logrotate"
      dest = "/etc/logrotate.d/#{application}"
      run "cmp -s #{src} #{dest} > /dev/null; [ $? -ne 0 ] && #{try_sudo} cp #{src} #{dest}; /bin/true"
      src = "#{release_path}/config/httpd/httpd.logrotate"
      dest = "/etc/logrotate.d/httpd"
      run "cmp -s #{src} #{dest} > /dev/null; [ $? -ne 0 ] && #{try_sudo} cp #{src} #{dest}; /bin/true"
    end
  end
end

before 'deploy:setup' do
  server_setup.rpm_install
  rvm.install_rvm
  rvm.install_ruby
  server_setup.rvm.trust
  server_setup.gem_install
  server_setup.passenger
end
after 'deploy:setup' do
  server_setup.filesystem.dir_perms
  server_setup.filesystem.mkdir_db_dumps
end
before 'deploy:update' do
  export_proxy
end
after 'deploy:update' do
  server_setup.logging.rotation
  server_setup.config.apache
  deploy.create_templates
  deploy.additional_symlinks
  deploy.restart
end

after 'deploy:finalize_update' do
  generate_database_yml

  #solved in Capfile
  #run "cd #{release_path}; RAILS_ENV=#{stage} rake assets:precompile"
end

namespace :deploy do

  # Passenger specifics: restart by touching the restart.txt file
  task :start, :roles => :app, :except => {:no_release => true} do
    restart
  end
  task :stop do
    ;
  end
  task :restart, :roles => :app, :except => {:no_release => true} do
    run "touch #{File.join(current_path, 'tmp', 'restart.txt')}"
  end

  # Remote bundle install
  task :rebundle do
    run "cd #{current_path} && bundle install"
    restart
  end

  task :bundle_update do
    run "cd #{current_path} && bundle update"
    restart
  end

  desc "Additional Symlinks to shared_path"
  task :additional_symlinks do
    run "rm -rf #{release_path}/tmp/shared_config"
    run "ln -nfs #{shared_path}/env_config #{release_path}/tmp/env_config"

    run "rm -f #{release_path}/db_dumps"
    run "ln -s #{shared_path}/db_dumps #{release_path}/db_dumps"
  end

  # Load the schema
  desc "Load the schema into the database (WARNING: destructive!)"
  task :schema_load, :roles => :db do
    run("cd #{current_path} && rake db:schema:load", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Run the sample data populator
  desc "Run the test data populator script to load test data into the db (WARNING: destructive!)"
  task :populate, :roles => :db do
    generate_populate_yml
    run("cd #{current_path} && rake db:populate", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Seed the db
  desc "Run the seeds script to load seed data into the db (WARNING: destructive!)"
  task :seed, :roles => :db do
    run("cd #{current_path} && rake db:seed", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Add an initial user
  desc "Adds an initial user to the app"
  task :add_initial_user, :roles => :db do

  end

  desc "Full redepoyment, it runs deploy:update and deploy:refresh_db"
  task :full_redeploy do
    update
    rebundle
    refresh_db
  end

  # Helper task which re-creates the database
  task :refresh_db, :roles => :db do
    require 'colorize'

    # Prompt to refresh_db on unless we're in QA
    if stage.eql?(:qa)
      input = "yes"
    else
      puts "This step (deploy:refresh_db) will erase all data and start from scratch.\nYou probably don't want to do it. Are you sure?' [NO/yes]".colorize(:red)
      input = STDIN.gets.chomp
    end

    if input.match(/^yes/)
      schema_load
      seed
      populate
    else
      puts "Skipping database nuke"
    end
  end

  desc "Safe redeployment"
  task :safe do # TODO roles?
    require 'colorize'
    update
    rebundle

    cat_migrations_output = capture("cd #{current_path} && rake db:cat_pending_migrations 2>&1", :env => {'RAILS_ENV' => stage}).chomp
    puts cat_migrations_output

    if cat_migrations_output != '0 pending migration(s)'
      print "There are pending migrations. Are you sure you want to continue? [NO/yes] ".colorize(:red)
      abort "Exiting because you didn't type 'yes'" unless STDIN.gets.chomp == 'yes'
    end

    backup.db.dump
    backup.db.trim
    migrate
    restart
  end

  desc 'Create extra config in central location'
  task :create_templates do
    require "yaml"

    config = YAML::load_file('config/dc21app_config.yml')
    file_path = "#{config[stage.to_s]['extra_config_file']}/dc21app_extra_config.yml"

    output = capture("ls #{config[stage.to_s]['extra_config_file_root']} | grep '^dc21app_extra_config.yml$'").strip

    if output.empty?
      run("cp #{current_path}/deploy_templates/dc21app_extra_config.yml #{config[stage.to_s]['extra_config_file_root']}", :env => {'RAILS_ENV' => "#{stage}"})
      print "\nNOTICE: Please update #{file_path} with the appropriate values and restart the server\n\n".colorize(:green)
    else
      print "\nALERT: Config file #{file_path} detected. Will not overwrite\n\n".colorize(:red)
    end

  end

end
