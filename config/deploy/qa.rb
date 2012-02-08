# Your HTTP server, Apache/etc
role :web, 'knt1-dc21-qa.intersect.org.au'
# This may be the same as your Web server
role :app, 'knt1-dc21-qa.intersect.org.au'
# This is where Rails migrations will run
role :db,  'knt1-dc21-qa.intersect.org.au', :primary => true

