def populate_data
  load_password
  create_test_users
  create_test_files
  create_facilities
  create_column_mappings
end

def create_test_files
  DataFile.delete_all
  ColumnDetail.delete_all
  MetadataItem.delete_all
  create_data_file("sample1.txt", "georgina@intersect.org.au")
  create_data_file("sample2.txt", "alexb@intersect.org.au")
  create_data_file("weather_station_15_min.dat", "alexb@intersect.org.au")
  create_data_file("weather_station_05_min.dat", "matthew@intersect.org.au")
  create_data_file("weather_station_table_2.dat", "kali@intersect.org.au")
  create_data_file("sample3.txt", "kali@intersect.org.au")
  create_data_file("WTC01_Table1.dat", "georgina@intersect.org.au")
  create_data_file("WTC02_Table1.dat", "alexb@intersect.org.au")
end

def create_test_users
  User.delete_all
  create_user(:email => "alexb@intersect.org.au", :first_name => "Alex", :last_name => "Bradner")
  create_user(:email => "georgina@intersect.org.au", :first_name => "Georgina", :last_name => "Edwards")
  create_user(:email => "matthew@intersect.org.au", :first_name => "Matthew", :last_name => "Hillman")
  create_user(:email => "kali@intersect.org.au", :first_name => "Kali", :last_name => "Waterford")
  create_user(:email => "researcher1@intersect.org.au", :first_name => "Researcher", :last_name => "One")
  r2 = create_user(:email => "researcher2@intersect.org.au", :first_name => "Researcher", :last_name => "Two")
  r2.deactivate
  create_rejected_user(:email => "rejected@intersect.org.au", :first_name => "Rejected", :last_name => "One")
  create_unapproved_user(:email => "unapproved1@intersect.org.au", :first_name => "Unapproved", :last_name => "One")
  create_unapproved_user(:email => "unapproved2@intersect.org.au", :first_name => "Unapproved", :last_name => "Two")
  set_role("alexb@intersect.org.au", "Administrator")
  set_role("georgina@intersect.org.au", "Administrator")
  set_role("matthew@intersect.org.au", "Administrator")
  set_role("kali@intersect.org.au", "Administrator")
  set_role("researcher1@intersect.org.au", "Researcher")
  set_role("researcher2@intersect.org.au", "Researcher")

end

def create_data_file(filename, uploader)
  # we use the attachment builder to create the sample files so we know they've been processed the same way as if uploaded
  file = Rack::Test::UploadedFile.new("#{Rails.root}/samples/#{filename}", "application/octet-stream")
  params = {:file_1 => file, :dirStruct => "[{\"file_1\":\"#{filename}\"}]"}
  builder = AttachmentBuilder.new(params, APP_CONFIG['files_root'], User.find_by_email(uploader), FileTypeDeterminer.new, MetadataExtractor.new)
  builder.build
  df = DataFile.last
  rand_mins = rand(10000)
  # make the created at semi-random
  df.created_at = df.created_at - rand_mins.minutes
  df.save!
end

def set_role(email, role)
  user = User.find_by_email(email)
  role = Role.find_by_name(role)
  user.role = role
  user.save!
end

def create_user(attrs)
  user = User.new(attrs.merge(:password => @password))
  user.activate
  user.save!
  user
end

def create_rejected_user(attrs)
  user = User.new(attrs.merge(:password => @password))
  user.status = "R"
  user.save!
  user
end

def create_unapproved_user(attrs)
  user = User.create!(attrs.merge(:password => @password))
  user.save!
  user
end

def get_file_path
  config_file = File.expand_path('../../../config/dc21_config.yml', __FILE__)
  config = YAML::load_file(config_file)
  env = ENV["RAILS_ENV"] || "development"
  config[env]['files_root']
end

def load_password
  password_file = File.expand_path("#{Rails.root}/tmp/env_config/sample_password.yml", __FILE__)
  if File.exists? password_file
    puts "Using sample user password from #{password_file}"
    password = YAML::load_file(password_file)
    @password = password[:password]
    return
  end

  if Rails.env.development?
    puts "#{password_file} missing.\n" +
         "Set sample user password:"
          input = STDIN.gets.chomp
          buffer = Hash[:password => input]
          Dir.mkdir("#{Rails.root}/tmp/env_config", 755) unless Dir.exists?("#{Rails.root}/tmp/env_config")
          File.open(password_file, 'w') do |out|
            YAML::dump(buffer, out)
          end
    @password = input
  else
    raise "No sample password file provided, and it is required for any environment that isn't development\n" +
              "Use capistrano's deploy:populate task to generate one'"
  end

end

def create_facilities
  Facility.delete_all
  create_facility(:name => "Rainout Shelter Weather Station", :code => "ROS_WS")
  create_facility(:name => "Test Facility", :code => "T1")
end

def create_facility(attrs)
  facility = Facility.new(attrs)
  facility.save!
  facility
end

def create_column_mappings
  ColumnMapping.delete_all
  create_mapping(:name => "Average Soil Temp (Probe1)", :code => "SoilTempProbe_Avg(1)")
  create_mapping(:name => "Average Soil Temp (Probe2)", :code => "SoilTempProbe_Avg(2)")
  create_mapping(:name => "Average Soil Temp (Probe3)", :code => "SoilTempProbe_Avg(3)")
  create_mapping(:name => "Average Soil Temp (Probe4)", :code => "SoilTempProbe_Avg(4)")
  create_mapping(:name => "Average Soil Temp (Probe5)", :code => "SoilTempProbe_Avg(5)")
  create_mapping(:name => "Average Soil Temp (Probe6)", :code => "SoilTempProbe_Avg(6)")
  create_mapping(:name => "Temperature", :code => "PTemp_C_Max")
  create_mapping(:name => "Temperature", :code => "PTemp")
  create_mapping(:name => "Wind Speed", :code => "WndSpd")
end

def create_mapping(attrs)
  mapping = ColumnMapping.new(attrs)
  mapping.save!
  mapping
end
