
require "#{Rails.root}/db/seed_helper.rb"

begin  
  namespace :db do  

    desc "Create sequences"
    task :create_sequences => :environment do
      create_sequences
    end

    desc "Drop sequences"
    task :drop_sequences => :environment do
      ActiveRecord::Base.establish_connection(Rails.env.to_sym)
      ActiveRecord::Base.connection.execute "DROP SEQUENCE IF EXISTS package_id_seq;"
    end
  end
end  
