# Your HTTP server, Apache/etc
role :web, 'hostname'
# This may be the same as your Web server
role :app, 'hostname.com'
# This is where Rails migrations will run
role :db,  'hostname.com', :primary => true

set :user, 'dc21'
