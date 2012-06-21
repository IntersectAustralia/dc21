begin
  namespace :db do

    desc "Adds an initial user to a deployed instance"
    task :add_initial_user => :environment do
      raise "This task does nothing until the app has been deployed via capistrano."
    end

  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end
