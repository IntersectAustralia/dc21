begin
	task :performance_test => :environment do 
	  10000.times do
	  	puts "upload"
	    create_data_file("sample1.txt", "researcher0@intersect.org.au")
	  end
	end
rescue Exception => e  
  puts e
end
