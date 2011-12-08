# Your HTTP server, Apache/etc
role :web, 'jp-dc21-staging.intersect.org.au'
# This may be the same as your Web server
role :app, 'jp-dc21-staging.intersect.org.au'
# This is where Rails migrations will run
role :db,  'jp-dc21-staging.intersect.org.au'

