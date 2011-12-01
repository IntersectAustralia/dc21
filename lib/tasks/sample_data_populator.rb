def populate_data

  User.delete_all

  create_test_users

  create_test_files
end

def create_test_files
  DataFile.create!(:format => "file", :path => "/data/dc21-data/sample.txt", :filename => "sample.txt", :created_by => User.first, :start_time => Time.now - 3.days, :end_time => Time.now - 1.day)
  DataFile.create!(:format => "file", :path => "/data/dc21-data/sample2.txt", :filename => "sample2.txt", :created_by => User.first, :start_time => Time.now - 3.years, :end_time => Time.now - 1.year)
  DataFile.create!(:format => "file", :path => "/data/dc21-data/sample3.txt", :filename => "sample3.txt", :created_by => User.last)
end

def create_test_users
  create_user(:email => "sean@intersect.org.au", :first_name => "Sean", :last_name => "McCarthy")
  create_user(:email => "georgina@intersect.org.au", :first_name => "Georgina", :last_name => "Edwards")
  create_user(:email => "veronica@intersect.org.au", :first_name => "Veronica", :last_name => "Luke")
  create_user(:email => "shuqian@intersect.org.au", :first_name => "Shuqian", :last_name => "Hon")
  create_unapproved_user(:email => "unapproved1@intersect.org.au", :first_name => "Unapproved", :last_name => "One")
  create_unapproved_user(:email => "unapproved2@intersect.org.au", :first_name => "Unapproved", :last_name => "Two")
  set_role("sean@intersect.org.au", "Administrator")
  set_role("georgina@intersect.org.au", "Administrator")
  set_role("veronica@intersect.org.au", "Administrator")
  set_role("raul@intersect.org.au", "Administrator")
  set_role("diego@intersect.org.au", "Administrator")
  set_role("shuqian@intersect.org.au", "Administrator")

end

def set_role(email, role)
  user      = User.where(:email => email).first
  role      = Role.where(:name => role).first
  user.role = role
  user.save!
end

def create_user(attrs)
  u = User.new(attrs.merge(:password => "Pass.123"))
  u.activate
  u.save!
end

def create_unapproved_user(attrs)
  u = User.create!(attrs.merge(:password => "Pass.123"))
  u.save!
end


