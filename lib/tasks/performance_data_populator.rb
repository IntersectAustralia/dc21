require 'fileutils'
require 'tempfile'

def populate_performance_data
	old_logger = ActiveRecord::Base.logger
	ActiveRecord::Base.logger = nil
	check_files
	load_password
	create_performance_users
	create_performance_facilities
	create_performance_files
	ActiveRecord::Base.logger = old_logger
end

def check_files
  files = ["EddyFlux_Delay_CSAT_20130331.dat", "EddyFlux_fast_std_20130417.dat", "Cntrl14_Table1_20130331.dat","cntl_test.dat","node-v0.10.5.pkg","WTC02_Table1.dat","sample1.txt"]
  absent = []
  files.each do |file|
  	absent << file unless File.exists?("#{APP_CONFIG['data_root']}/perf_samples/#{file}")
  end

  if absent.count > 0
  	raise IOError, "Missing files #{absent.join(', ')} in #{APP_CONFIG['data_root']}/perf_samples/"
  end
end

def create_performance_users
	User.delete_all

	# populate 25 researchers
	$index = 0
	while $index < 25 do
		create_user(:email => "researcher"+$index.to_s+"@intersect.org.au", :first_name => "Researcher", :last_name => "User")
		set_role("researcher"+$index.to_s+"@intersect.org.au", "Researcher")
		puts "Creating user: researcher"+ $index.to_s
		$index += 1
	end

	# populate 5 admins
	$index = 0
	while $index < 5 do
		create_user(:email => "admin"+$index.to_s+"@intersect.org.au", :first_name => "Admin", :last_name => "User")
		set_role("admin"+$index.to_s+"@intersect.org.au", "Administrator")
		puts "Creating user: admin"+ $index.to_s
		$index += 1
	end

	# populate 4 API uploaders
	$index = 0
	while $index < 4 do
		create_user(:email => "uploader"+$index.to_s+"@intersect.org.au", :first_name => "Uploader", :last_name => "User")
		set_role("uploader"+$index.to_s+"@intersect.org.au", "API Uploader")
		puts "Creating user: uploader"+ $index.to_s
		$index += 1
	end
end

def create_performance_files
	DataFile.delete_all
	ColumnDetail.delete_all
	MetadataItem.delete_all

	# for 5 years new files + 1 year backlog of 35424 files in total
	# get monthly total * 72
		$index = 1
		# populate 203 RAW per month
			# Auto-upload Eddy+ROS+WS+WTC Raw per month 70
	72.times do
		69.times do
			puts "Uploading file "+ $index.to_s + ": EddyFlux_Delay_CSAT_20130331.dat"
			upload_toa5_file("EddyFlux_Delay_CSAT_20130331.dat", "researcher0@intersect.org.au")
			$index += 1
		end

		# This file has not been committed and should be manually placed in the server
		puts "Uploading 110MB file "+ $index.to_s + ": EddyFlux_fast_std_20130417.dat"
		upload_toa5_file("EddyFlux_fast_std_20130417.dat", "researcher0@intersect.org.au")
		$index += 1

			# Auto-upload Face Raw per month 25
		25.times do
			puts "Uploading file "+ $index.to_s + ": Cntrl14_Table1_20130331.dat"
			upload_toa5_file("Cntrl14_Table1_20130331.dat", "researcher0@intersect.org.au")
			$index += 1
		end

			# Manual upload Raw per month 108
		108.times do
			puts "Uploading file "+ $index.to_s + ": cntl_test.dat"
			upload_toa5_file("cntl_test.dat", "researcher0@intersect.org.au")
			$index += 1
		end

		# populate 203 Cleansed per month
		203.times do
			puts "Uploading file "+ $index.to_s + ": node-v0.10.5.pkg"
			create_data_file_performance("node-v0.10.5.pkg", "CLEANSED", "researcher0@intersect.org.au")
			$index += 1
		end

		# populate 41 Analysed per month
		41.times do
			puts "Uploading file "+ $index.to_s + ": WTC02_Table1.dat"
			create_data_file_performance("WTC02_Table1.dat", "PROCESSED", "researcher0@intersect.org.au")
			$index += 1
		end

		# populate 45 packagers per month
		45.times do
			puts "Uploading file "+ $index.to_s + ": sample1.txt"
			create_data_file_performance("sample1.txt", "RAW", "researcher0@intersect.org.au")
			$index += 1
		end
	end

end

def create_performance_facilities
	Facility.delete_all
	Experiment.delete_all
	user = User.first
	# Total number of facilities 20
	$index = 1
	20.times do
		puts "Creating facility: "+ "Facility"+$index.to_s
		ws = create_facility(:name => "Facility"+$index.to_s, :code => "ROS_WS_"+$index.to_s, :primary_contact => user)
		# Maximum number of experiments in a facility 50
		$eindex = 1
		5.times do
			puts "Creating experiment: "+ "Experiment"+$index.to_s+"_"+$eindex.to_s
			ws.experiments.create!(:name => "Experiment"+$index.to_s+"_"+$eindex.to_s, :start_date => "2012-01-01", :access_rights => "http://creativecommons.org/licenses/by-sa/3.0/au", :subject => "Rain")
			$eindex += 1
		end
		$index += 1
	end

	# Total number of manual experiments 50
	# Total number of Experiments 200
	"Creating facility: Test Facility"
	test = create_facility(:name => "Test Facility", :code => "T1", :primary_contact => user)
	$eindex = 1
	50.times do
		puts "Creating experiment: "+ "Text_experiment"+$eindex.to_s
		test.experiments.create(:name => "Text_experiment"+$eindex.to_s, :start_date => "2012-01-01", :access_rights => "http://creativecommons.org/licenses/by-sa/3.0/au", :subject => "Test1")
		$eindex += 1
	end

	"Creating facility: Other"
	other = create_facility(:name => "Other", :code => "Other Code", :primary_contact => user)
	#other.id = -1
	$eindex = 1
	50.times do
		puts "Creating experiment: "+ "Other"+$eindex.to_s
		other_experiment = other.experiments.create(:name => "Other"+$eindex.to_s, :start_date => "2012-01-01", :access_rights => "http://creativecommons.org/licenses/by-sa/3.0/au", :subject => "Other subject")
		$eindex += 1
	end
end

def create_data_file_performance(filename, type, uploader)
  # we use the attachment builder to create the sample files so we know they've been processed the same way as if uploaded
  file = Rack::Test::UploadedFile.new("#{APP_CONFIG['data_root']}/perf_samples/#{filename}", "application/octet-stream")
  builder = AttachmentBuilder.new(APP_CONFIG['files_root'], User.find_for_authentication(email: uploader), FileTypeDeterminer.new, MetadataExtractor.new)
  experiment_id = Experiment.first.id

  builder.build(file, experiment_id, type, "")
  df = DataFile.last
  rand_mins = rand(10000)
  # make the created at semi-random
  df.created_at = df.created_at - rand_mins.minutes
  df.save!
end

def upload_toa5_file(filename, uploader)
	filepath = "#{APP_CONFIG['data_root']}/perf_samples/#{filename}"
	if File.exists?(filepath)
		create_data_file_performance(filename, 'RAW', uploader)

		t_file = Tempfile.new('filename_temp.txt')

	  File.open(filepath, 'r') do |f|
	    f.each_line{|line| t_file.puts line.gsub(/(^["])(\d+)([-])/){|not_need| "\""+($2.to_i+1).to_s+'-'}}
	  end
  	FileUtils.mv(t_file.path, filepath)
	else
		puts "#{filepath} does not exist!"
	end
end
