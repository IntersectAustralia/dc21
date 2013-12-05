require 'rvm/capistrano'
require 'capistrano/ext/multistage'
require 'bundler/capistrano'
require 'capistrano_colors'
require 'colorize'
require 'deploy/create_deployment_record'

# Extra capistrano tasks
Dir["config/recipes/*.rb"].each {|file| load file }

set :keep_releases, 5
set :application, 'dc21app'
set :stages, %w(qa staging production local)
set :default_stage, "qa"

set :shared_children, shared_children + %w(log_archive)
set :bash, '/bin/bash'
set :shell, bash
set :rvm_ruby_string, 'ruby-1.9.2-p290@dc21app'

set :bundle_flags, "--deployment"

# Deploy using copy for now
set :scm, 'git'
set :repository, 'git://github.com/IntersectAustralia/dc21.git'
set :deploy_via, :remote_cache
set :copy_cache, true
set :copy_exclude, ["features/*", "spec/*", "performance/*"]

set :branch do
  default_tag = 'HEAD'

  puts "    Availible tags:".yellow
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

# Capistrano hooks
before 'deploy:setup' do
  server_setup.aaf_install
  server_setup.gem_install
  server_setup.passenger
  postgresql.setup
  joai.setup
  resque.setup
end

after 'deploy:setup' do
  server_setup.filesystem.dir_perms
  server_setup.filesystem.mkdir_db_dumps
  server_setup.logging.rotation
  server_setup.config.apache
  server_setup.config.cron
end

before 'deploy:update' do
  export_proxy
end

after 'deploy:update' do
  deploy.additional_symlinks
  deploy.write_tag
  deploy.create_sequences
  deploy.new_secret
  deploy.cleanup
  deploy.restart
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
      puts "    This step (deploy:refresh_db) will erase all data and start from scratch.\nYou probably don't want to do it. Are you sure?' [NO/yes]".red
      input = STDIN.gets.chomp
    end

    if input.match(/^yes/)
      `rm -rf #{data_dir}`
      server_setup.filesystem.dir_perms
      schema_load
      seed
      populate
    else
      puts "    Skipping database nuke".blue
    end
  end

  desc "Safe redeployment"
  task :safe do # TODO roles?
    require 'colorize'
    update

    cat_migrations_output = capture("cd #{current_path} && bundle exec rake db:cat_pending_migrations 2>&1", :env => {'RAILS_ENV' => stage}).chomp
    puts cat_migrations_output.blue

    unless cat_migrations_output[/0 pending migration\(s\)/]
      print "    There are pending migrations. Are you sure you want to continue? [NO/yes] ".red
      abort "    Exiting because you didn't type 'yes'" unless STDIN.gets.chomp == 'yes'
    end

    backup.db.dump
    backup.db.trim
    migrate
  end

  # namespace :assets do
  #   task :precompile, :roles => :web, :except => { :no_release => true } do
  #     from = source.next_revision(current_revision)
  #     if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
  #       run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
  #     else
  #       logger.info "Skipping asset pre-compilation because there were no asset changes"
  #     end
  #   end
  # end

  desc "Restart all services"
  task :start_services, on_error: :continue do
    sudo "service tomcat restart"
    sudo "service redis restart"
    sudo "service postgresql restart"
    sudo "service shibd restart"
    sudo "service httpd restart"
  end

  desc "Print all services"
  task :check_services, on_error: :continue do
    sudo "service tomcat status | cat"
    sudo "service redis status | cat"
    sudo "service postgresql status | cat"
    sudo "service shibd status | cat"
    sudo "service httpd status | cat"
  end


  desc "Runs all the first time setup tasks"
  task :first_time, :except => {:no_release => true} do
    deploy.setup
    server_setup.set_proxies
    deploy.update
    deploy.schema_load
    deploy.seed
    deploy.generate_initial_user
    deploy.start_services
    deploy.start
    deploy.check_services
  end

end
