# Your HTTP server, Apache/etc
set :web_server, 'hostname.com'
# This may be the same as your Web server
set :app_server, 'hostname.com'
# This is where Rails migrations will run
set :db_server, 'hostname.com'
# The user configured to run the rails app
set :user, 'dc21'

# If you are using RHEL/CentOS 6 or later, set this to true
set :centos_6, true

# If you have a proxy server, enter the value here in "inverted commas", eg:
#set :proxy, "http://user:pass@proxy.example.com:8080" # with a user/password
#set :proxy, "http://proxy.example.com:8080" # without a user/pass
set :proxy, nil


role :web, web_server
role :app, app_server
role :db,  db_server, :primary => true


