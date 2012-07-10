require "highline/import"
require 'colorize'


namespace :backup do
  namespace :db do
    desc "make a database backup"
    task :dump do
      run "cd #{current_path} && rake db:backup", :env => {'RAILS_ENV' => stage}
    end

    desc "trim database backups"
    task :trim do
      run "cd #{current_path} && rake db:trim_backups", :env => {'RAILS_ENV' => stage}
    end
  end
end

desc "Give sample users a custom password"
task :generate_populate_yml, :roles => :app do
  do_set_password if agree("Set sample user password? (required on initial deploy)".colorize(:red) { |q| q.default = 'no' })
end

desc "Helper method that actually sets the sample user password"
task :do_set_password, :roles => :app do
  require "yaml"
  set :custom_sample_password, proc { Capistrano::CLI.password_prompt("Sample User password: ") }
  buffer = Hash[:password => custom_sample_password]
  put YAML::dump(buffer), "#{shared_path}/env_config/sample_password.yml", :mode => 0664
end

desc "After updating code we need to populate a new database.yml"
task :generate_database_yml, :roles => :app do
  require "yaml"

  set :production_database_password, proc { Capistrano::CLI.password_prompt("Database password: ") }

  buffer = YAML::load_file('config/database.yml')
  # get rid of unneeded configurations
  buffer.delete('test')
  buffer.delete('development')
  buffer.delete('cucumber')
  buffer.delete('spec')

  # Populate production password
  buffer[rails_env]['password'] = production_database_password

  put YAML::dump(buffer), "#{release_path}/config/database.yml", :mode => 0664
end


namespace :deploy do

  #There's a little bit of reinventing the wheel here (user validation), but we don't want to boot up the rails app in the middle of a deploy
  desc "On a new deploy we need an initial user and password"
  task :generate_initial_user do
    require 'rails' # So we can use bits of our validator
    require "#{File.dirname(__FILE__)}/../lib/password_format_validator"

    output_file = "#{current_path}/config/initial_user.yml"
    user_happy = false
    user = {}
    until user_happy
      normal_attrs = [:first_name, :last_name, :email]
      user = {}
      puts 'Enter details for a new admin user:'.yellow
      puts "Warning: Everything you enter will be temporarily stored on the server in:".red,
           output_file,
           "This file will be deleted if deployment completes successfully,".red,
           "however you should ensure that file is removed if this step fails.".red


      normal_attrs.each do |attr|
        user[attr] = get_attr("#{attr.to_s.humanize}:".yellow)
      end

      #get a password
      until user[:password]
        password = Capistrano::CLI.password_prompt("New user password: ".yellow)
        conf_password = Capistrano::CLI.password_prompt("confirm password: ".yellow)

        if password.eql? conf_password
          if password =~ PasswordFormatValidator::PASS_REGEX
            user[:password] = password
          else
            puts PasswordFormatValidator::FAIL_STRING
          end
        else
          puts "Passwords don't match".red
        end
      end

      puts "Name: #{user[:first_name] + ' ' + user[:last_name]}",
           "Email: #{user[:email]}",
           "Password: <hidden>"
      user_happy = agree "Is this okay?"

    end

    # convert HighLine::String to String
    user.each { |key, str| user[key] = str.to_s } #This is effectively Hash.map!

    #push and execute rake task
    begin
      put YAML::dump(user), output_file, :mode => 0664
      run("cd #{current_path} && rake db:add_initial_user", :env => {'RAILS_ENV' => "#{stage}"})
    ensure
      run "rm -f #{output_file}"
    end

  end

end

task :export_proxy do
  run "export http_proxy=#{proxy}" if proxy
end


after 'multistage:ensure' do
  set (:rails_env) do
    "#{defined?(rails_env) ? rails_env : stage.to_s}"
  end
end

def get_attr(attr)
  ask(attr) do |q|
    q.validate = /\A\w.*\Z/i
    q.responses[:not_valid] = 'This field cannot be blank.'.red
    q.responses[:ask_on_error] = :question
  end
end

def user_says_yes?(in_str)
  in_str.downcase.match(/^y(es)?/)
end