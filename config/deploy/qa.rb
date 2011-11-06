# Your HTTP server, Apache/etc
role :web, 'QATODO'
# This may be the same as your Web server
role :app, 'QATODO'
# This is where Rails migrations will run
role :db,  'QATODO'

