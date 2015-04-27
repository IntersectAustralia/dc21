Given /^I log in via AAF as "([^"]*)"$/ do |email|

  require 'jwt'

  iat = Time.now

  # See config/aaf_rc.yml for secret token and aud attribute
  aaf_rc_params = {"iat" => iat.to_i,
                   "nbf" => (iat - 1.minute).to_i,
                   "exp" => (iat + 3.minutes).to_i,
                   "typ" => "authnresponse",
                   "https://aaf.edu.au/attributes" =>
                       {
                           "cn" => 'Test AAF',
                           "displayname" => 'Test AAF',
                           "surname" => 'AAF',
                           "givenname" => 'Test',
                           "mail" => email,
                           "edupersonprincipalname" => email
                       },
                   "iss" => "https://rapid.test.aaf.edu.au",
                   "aud" => "http://example.com/"
  }
  jwt_token = JWT.encode(aaf_rc_params, 'Test')

  page.driver.post('/users/aaf_sign_in', {assertion: jwt_token})
end

Given /^I have a user "([^"]*)"$/ do |email|
  Factory(:user, :email => email, :password => "Pas$w0rd", :status => 'A')
end

Given /^I have a user "([^"]*)" with name "([^"]*)" "([^"]*)"$/ do |email, first, last|
  Factory(:user, :email => email, :password => "Pas$w0rd", :status => 'A', :first_name => first, :last_name => last)
end

Given /^I have a locked user "([^"]*)"$/ do |email|
  Factory(:user, :email => email, :password => "Pas$w0rd", :status => 'A', :locked_at => Time.now - 30.minute, :failed_attempts => 3)
end

Given /^I have a deactivated user "([^"]*)"$/ do |email|
  Factory(:user, :email => email, :password => "Pas$w0rd", :status => 'D')
end

Given /^I have a rejected as spam user "([^"]*)"$/ do |email|
  Factory(:user, :email => email, :password => "Pas$w0rd", :status => 'R')
end

Given /^I have a pending approval user "([^"]*)"$/ do |email|
  Factory(:user, :email => email, :password => "Pas$w0rd", :status => 'U')
end

Given /^I have a user "([^"]*)" with an expired lock$/ do |email|
  Factory(:user, :email => email, :password => "Pas$w0rd", :status => 'A', :locked_at => Time.now - 1.hour - 1.second, :failed_attempts => 3)
end

def set_user_role(user, role_name)
  role = Role.find_or_create_by_name(role_name)
  user.role_id = role.id
  user.save!
end

Given /^I have a user "([^"]*)" with role "([^"]*)"$/ do |email, role|
  user = Factory(:user, :email => email, :password => "Pas$w0rd", :status => 'A')
  set_user_role(user, role)
end

Given /^I am logged in as "([^"]*)"$/ do |email|
  unless User.find_for_authentication(email: email)
    user = Factory(:user, :email => email, :password => "Pas$w0rd", :status => 'A')
    set_user_role(user, "Administrator")
  end
  visit path_to("the login page")
  fill_in("user_email", :with => email)
  fill_in("user_password", :with => "Pas$w0rd")
  click_button("Log in")
end

Then /^I should be able to log in with "([^"]*)" and "([^"]*)"$/ do |email, password|
  visit path_to("the logout page")
  visit path_to("the login page")
  fill_in("user_email", :with => email)
  fill_in("user_password", :with => password)
  click_button("Log in")
  page.should have_content('Logged in successfully.')
  current_path.should == path_to('the home page')
end

When /^I attempt to login with "([^"]*)" and "([^"]*)"$/ do |email, password|
  visit path_to("the login page")
  fill_in("user_email", :with => email)
  fill_in("user_password", :with => password)
  click_button("Log in")
end

When /^I logout$/ do
  visit path_to("the logout page")
end

Then /^the failed attempt count for "([^"]*)" should be "([^"]*)"$/ do |email, count|
  user = User.where(:email => email).first
  user.failed_attempts.should == count.to_i
end

And /^I request a reset for "([^"]*)"$/ do |email|
  visit path_to("the home page")
  click_link "Forgot your password?"
  fill_in "Email", :with => email
  click_button "Send me reset password instructions"
end

When /^I attempt to change my password with old password "([^"]*)", new password "([^"]*)" and confirmation "([^"]*)"$/ do |old, new, confirm_new|
  visit path_to("the home page")
  click_link ("Settings")
  click_link("Change Password")
  fill_in("New password", :with => new)
  fill_in("Confirm new password", :with => confirm_new)
  fill_in("Current password", :with => old)
  click_button("Update")
end
