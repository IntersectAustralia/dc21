require 'rvm/capistrano'
require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'capistrano_colors'
require 'colorize'
require 'deploy/create_deployment_record'

# Extra capistrano tasks
load 'config/recipes/intersect_capistrano_tasks'
load 'config/recipes/joai_capistrano_tasks'
load 'config/recipes/resque'
load 'config/recipes/postgresql'
load 'config/recipes/server_setup'
load 'config/recipes/shared_file'

set :keep_releases, 5
set :application, 'dc21app'
set :stages, %w(qa staging production nectar-demo production_local)
set :default_stage, "qa"

set :shared_children, shared_children + %w(log_archive)
set :bash, '/bin/bash'
set :shell, bash # This is don in two lines to allow rpm_install to refer to bash (as shell just launches cap shell)
set :rvm_ruby_string, 'ruby-1.9.2-p290@dc21app'

set :bundle_flags, "--deployment"

# Deploy using copy for now
set :scm, 'git'
set :repository, 'git://github.com/IntersectAustralia/dc21.git'
set :deploy_via, :copy
set :copy_exclude, ["features/*", "spec/*", "performance/*"]

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
set(:data_dir) { "#{defined?(data_dir) ? data_dir : '/data/dc21-data'}" }
set(:aux_data_dir) { "#{defined?(aux_data_dir) ? aux_data_dir : '/data/dc21-data'}" }
set(:rif_cs_dir) { "#{defined?(rif_cs_dir) ? rif_cs_dir : '/data/dc21-data/published_rif_cs/'}" }
set(:unpublished_rif_cs_dir) { "#{defined?(unpublished_rif_cs_dir) ? unpublished_rif_cs_dir : '/data/dc21-data/unpublished_rif_cs/'}" }
set(:archived_dir) { "#{defined?(archived_dir) ? archived_dir : '/data/dc21-data/archived_data/'}" }
set :normalize_asset_timestamps, false

default_run_options[:pty] = true


after 'deploy:update' do
  deploy.additional_symlinks
  deploy.write_tag
  deploy.create_sequences
  deploy.create_deployment_record
  deploy.new_secret
  deploy.restart
  deploy.cleanup
end

after 'deploy:finalize_update' do
  deploy.create_templates
end

namespace :deploy do
  task :new_secret, :roles => :app do
    run("cd #{current_path} && bundle exec rake app:generate_secret", :env => {'RAILS_ENV' => "#{stage}"})
  end
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

  # Create sequences
  desc "Create sequences for packages"
  task :create_sequences, :roles => :db do
    run("cd #{current_path} && bundle exec rake db:create_sequences", :env => {'RAILS_ENV' => "#{stage}"})
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
      `rm -rf #{data_dir}`
      server_setup.filesystem.dir_perms
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

    cat_migrations_output = capture("cd #{current_path} && bundle exec rake db:cat_pending_migrations 2>&1", :env => {'RAILS_ENV' => stage}).chomp
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

  desc "Runs all the first time setup tasks"
  task :first_time, :except => {:no_release => true} do
    deploy.setup
    deploy.update
    deploy.schema_load
    deploy.seed
    deploy.generate_initial_user
    deploy.restart

  end

end
