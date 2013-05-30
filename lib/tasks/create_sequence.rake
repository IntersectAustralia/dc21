begin  
  namespace :db do  

    desc "Create sequences"
    task :create_sequences => :environment do
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      result = ActiveRecord::Base.connection.execute "SELECT * FROM information_schema.sequences WHERE sequence_schema = 'public' AND sequence_name = 'package_id_seq';"
      ActiveRecord::Base.connection.execute "CREATE SEQUENCE package_id_seq;" unless result.count
    end

    desc "Drop sequences"
    task :drop_sequences => :environment do
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      ActiveRecord::Base.connection.execute "DROP SEQUENCE IF EXISTS package_id_seq;"
    end
  end
end  
