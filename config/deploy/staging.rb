# Your HTTP server, Apache/etc
role :web, 'STAGING'
# This may be the same as your Web server
role :app, 'STAGING'
# This is where Rails migrations will run
role :db,  'STAGING'

