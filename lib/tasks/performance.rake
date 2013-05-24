require File.dirname(__FILE__) + '/performance_data_populator.rb'
begin

	task :performance => :environment do 
	  populate_performance_data
	end
rescue Exception => e  
  puts e
end

