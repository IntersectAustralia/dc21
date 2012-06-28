Given /^user "([^"]*)" has an API token$/ do |email|
  user = User.find_by_email!(email)
  user.reset_authentication_token!
end

When /^I submit an API upload request without an API token$/ do
  post api_create_data_files_path(:format => :json)
end

Then /^I should get a (\d+) response code$/ do |status|
  last_response.status.should == status.to_i
end

