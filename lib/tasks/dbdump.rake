require File.dirname(__FILE__) + '/db_backup.rb'
begin  
  namespace :db do  

    desc "Backup the database"
    task :backup => :environment do  
      output_dir = '/tmp'
      db_backup output_dir
    end

    desc "Backup the database"
    task :trim_backups => :environment do
      output_dir = '/tmp'
      at_most = 5
      trim_backups output_dir, at_most
    end
  end  
end
