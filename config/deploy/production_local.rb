set :user, 'dc21'
set :deploy_base, "/home/#{user}"
set :use_sudo, true
set :copy_dir, "/home/#{user}/tmp"
set :remote_copy_dir, "/tmp"
set :rails_env, "production"
set :stage, "production"
set :branch, ENV['DC21_TAG'] unless ENV['DC21_TAG']

# Your HTTP server, Apache/etc
set :web_server, 'HOSTNAME'
# # This may be the same as your Web server
set :app_server, 'HOSTNAME'
# # This is where Rails migrations will run
set :db_server, 'HOSTNAME'
# # The user configured to run the rails app

# Your HTTP server, Apache/etc
role :web, ''
# This may be the same as your Web server
role :app, ''
# This is where Rails migrations will run
role :db,  '', :primary => true

# If you are using RHEL/CentOS 6 or later, set this to true
set :el6, true

# If you have a proxy server, enter the value here in "inverted commas", eg:
#set :proxy, "http://user:pass@proxy.example.com:8080" # with a user/password
#set :proxy, "http://proxy.example.com:8080" # without a user/pass
set :proxy, nil
