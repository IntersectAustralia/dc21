begin
  namespace :db do

    desc "Adds an initial user to a deployed instance"
    task :add_initial_user => :environment do
      require 'yaml'

      raise 'Cannot add an initial user, there are already administrators in the database' unless User.approved_superusers.count.eql? 0
      raise 'Cannot add an initial user, there are no roles specified. Please seed first' if Role.count.eql? 0

      user_file = File.expand_path("#{Rails.root}/tmp/env_config/sample_password.yml", __FILE__)
      raise "Cannot continue! Could not find #{user_file}" unless File.exists? user_file
      user_attrs = YAML::load_file(config_file)

      user = User.new(user_attrs)
      role = Role.find_by_name("Administrator")
      user.role = role
      user.activate
      user.save!
    end

  end
rescue LoadError
  puts "It looks like some Gems are missing: please run bundle install"
end
