require 'rvm/capistrano'
require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'capistrano_colors'
require 'colorize'

# Extra capistrano tasks
load 'lib/intersect_capistrano_tasks'
load 'lib/joai_capistrano_tasks'

set :keep_releases, 5
set :application, 'dc21app'
set :stages, %w(qa staging production)
set :default_stage, "qa"

set :shared_children, shared_children + %w(log_archive)
set :bash, '/bin/bash'
set :shell, bash # This is don in two lines to allow rpm_install to refer to bash (as shell just launches cap shell)
set :rvm_ruby_string, 'ruby-1.9.2-p290@dc21app'

set :bundle_flags, "--deployment"

# Deploy using copy for now
set :scm, 'git'
#set :repository, 'ssh://git.intersect.org.au/git/dc21'
set :repository, 'https://github.com/IntersectAustralia/dc21.git'
set :deploy_via, :copy
set :copy_exclude, [".git/*"]

set :branch do
  default_tag = 'HEAD'

  puts "Availible tags:".yellow
  puts `git tag`
  tag = Capistrano::CLI.ui.ask "Tag to deploy (make sure to push the branch/tag first) or HEAD?: [#{default_tag}] ".yellow
  tag = default_tag if tag.empty?
  tag
end

set(:user) { "#{defined?(user) ? user : 'devel'}" }
set(:group) { "#{defined?(group) ? group : user}" }
set(:user_home) { "/home/#{user}" }
set(:deploy_to) { "#{user_home}/#{application}" }
set(:data_dir) { "#{defined?(data_dir) ? data_dir : '/data/dc21-samples'}" }
set(:aux_data_dir) { "#{defined?(aux_data_dir) ? aux_data_dir : '/data/dc21-data'}" }
set(:rif_cs_dir) { "#{defined?(rif_cs_dir) ? rif_cs_dir : '/data/dc21-data/published_rif_cs/'}" }
set(:unpublished_rif_cs_dir) { "#{defined?(unpublished_rif_cs_dir) ? unpublished_rif_cs_dir : '/data/dc21-data/unpublished_rif_cs/'}" }
set(:archived_dir) { "#{defined?(archived_dir) ? archived_dir : '/data/dc21-data/archived_data/'}" }
set :normalize_asset_timestamps, false

default_run_options[:pty] = true

namespace :server_setup do
  task :set_proxies do
    unless proxy.nil?
      run "echo 'export http_proxy=\"#{proxy}\"' >> ~#{user}/.bashrc", :shell => bash
      run "echo 'export HTTP_PROXY=$http_proxy' >> ~#{user}/.bashrc", :shell => bash

      run "echo 'echo \'export http_proxy=\"#{proxy}\"\' >> /etc/bashrc' | #{try_sudo} /bin/bash", :shell => bash
      run "echo 'echo \'export HTTP_PROXY=$http_proxy\' >> /etc/bashrc' | #{try_sudo} /bin/bash" , :shell => bash

      run "echo 'proxy=\"#{proxy}\"' >> ~#{user}/.curlrc", :shell => bash
      run "echo '---' >> ~#{user}/.gemrc", :shell => bash
      run "echo 'http-proxy: \"#{proxy}\"' >> ~#{user}/.gemrc", :shell => bash
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
      run "[[ -d #{unpublished_rif_cs_dir} ]] || #{try_sudo} mkdir -p #{unpublished_rif_cs_dir}"
      run "#{try_sudo} chown -R #{user}.#{group} #{unpublished_rif_cs_dir}"
      run "[[ -d #{archived_dir} ]] || #{try_sudo} mkdir -p #{archived_dir}"
      run "#{try_sudo} chown -R #{user}.#{group} #{archived_dir}"
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
    run "gem install bundler -v 1.0.20"
    run "gem install passenger"
  end
  task :passenger, :roles => :app do
    run "passenger-install-apache2-module -a"
  end
  namespace :config do
    task :apache do
      run "mkdir -p apache_config"
      upload "config/httpd", "apache_config", :via => :scp, :recursive => true

      run "cd apache_config/httpd && ruby passenger_setup.rb \"#{rvm_ruby_string}\" \"#{current_path}\" \"#{web_server}\" \"#{stage}\""
      src = "apache_config/httpd/apache_insertion.conf"
      dest = "/etc/httpd/conf.d/rails_#{application}.conf"
      run "cmp -s #{src} #{dest} > /dev/null; [ $? -ne 0 ] && #{try_sudo} cp #{src} #{dest} ; /bin/true"
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
  server_setup.rvm.trust
  server_setup.gem_install
  server_setup.passenger
end
after 'deploy:setup' do
  server_setup.filesystem.dir_perms
  server_setup.filesystem.mkdir_db_dumps

  server_setup.logging.rotation
  server_setup.config.apache
end
before 'deploy:update' do
  export_proxy
end
after 'deploy:update' do
  deploy.additional_symlinks
  deploy.write_tag
  deploy.restart
end

after 'deploy:finalize_update' do
  generate_database_yml
  deploy.create_templates
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

  desc "Write the tag that was deployed to a file on the server so we can display it on the app"
  task :write_tag do
    if branch.eql?("HEAD")
      put "<a href='https://github.com/IntersectAustralia/dc21/tree/#{`git log -1 --pretty="format:%H"`}'>HEAD</a>", "#{release_path}/app/views/shared/_tag.html.haml"
    else
      put branch, "#{release_path}/app/views/shared/_tag.html.haml"
    end
  end

  # Load the schema
  desc "Load the schema into the database (WARNING: destructive!)"
  task :schema_load, :roles => :db do
    run("cd #{current_path} && bundle exec rake db:schema:load", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Run the sample data populator
  desc "Run the test data populator script to load test data into the db (WARNING: destructive!)"
  task :populate, :roles => :db do
    generate_populate_yml
    run("cd #{current_path} && bundle exec rake db:populate", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Run the performance test data populator
  desc "Run the performance test data populator script to load test data into the db (WARNING: destructive!)"
  task :performance_populate, :roles => :db do
    run("cd #{current_path} && bundle exec rake performance", :env => {'RAILS_ENV' => "#{stage}"})
  end

  # Seed the db
  desc "Run the seeds script to load seed data into the db (WARNING: destructive!)"
  task :seed, :roles => :db do
    run("cd #{current_path} && bundle exec rake db:seed", :env => {'RAILS_ENV' => "#{stage}"})
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

    unless cat_migrations_output[/0 pending migration\(s\)/]
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
    file_path = "#{config[stage.to_s]['extra_config_file_root']}/dc21app_extra_config.yml"
    output = capture("ls #{config[stage.to_s]['extra_config_file_root']}").strip

    if output[/dc21app_extra_config\.yml/].nil?
      run "#{try_sudo} chown -R #{user}.#{group} #{config[stage.to_s]['extra_config_file_root']}"
      run("cp #{release_path}/deploy_templates/dc21app_extra_config.yml #{config[stage.to_s]['extra_config_file_root']}", :env => {'RAILS_ENV' => "#{stage}"})
      print "\nNOTICE: Please update #{file_path} with the appropriate values and restart the server\n\n".colorize(:green)
    else
      print "\nALERT: Config file #{file_path} detected. Will not overwrite\n\n".colorize(:red)
    end

  end

end
