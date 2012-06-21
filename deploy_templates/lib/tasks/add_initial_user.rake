begin
  namespace :db do

    desc "Adds an initial user to a deployed instance"
    task :add_initial_user => :environment do

      #### EDIT BELOW THIS LINE
      customised = false # Set this to true
      user_attrs = {
          :email => "user@host",
          :first_name => "First",
          :last_name => "Last",
          :password => 'change me' # Use a temporary password, and change this when you first log in.
      }
      #### EDIT ABOVE THIS LINE

      raise 'Cannot add an initial user, there are already users in the database' unless User.count.eql? 0
      raise 'Cannot add an initial user, there are no roles specified. Please seed first' if Role.count.eql? 0
      raise 'Add Initial User task has not been customised. Cannot continue!' unless customised
      raise 'Initial User Password has not been changed' if user_attrs[:password].eql? 'change me'

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
