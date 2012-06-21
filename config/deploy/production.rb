# Your HTTP server, Apache/etc
set :web_server, 'hostname.com'
# This may be the same as your Web server
set :app_server, 'hostname.com'
# This is where Rails migrations will run
set :db_server, 'hostname.com'
# The user configured to run the rails app
set :user, 'dc21'



role :web, web_server
role :app, app_server
role :db,  db_server, :primary => true


