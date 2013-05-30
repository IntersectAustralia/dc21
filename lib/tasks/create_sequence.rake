begin  
  namespace :db do  

    desc "Create sequences"
    task :create_sequences => :environment do  
      ActiveRecord::Base.connection.execute 'CREATE SEQUENCE package_id_seq;'
    end
  end  
end
