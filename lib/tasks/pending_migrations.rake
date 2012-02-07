require File.dirname(__FILE__) + '/pending_migrations.rb'
begin
  namespace :db do

    desc "show pending migrations"
    task :cat_pending_migrations => :environment do
      cat_pending_migrations
    end

    desc "confirm migrations if any"
    task :confirm_pending_migrations => :environment do
      if any_pending_migrations?
        cat_pending_migrations
        print 'are you sure you want to migrate? [NO/yes] '
        input = STDIN.gets
        raise 'user requested exit' unless input == 'yes'
      end
    end
  end
end
