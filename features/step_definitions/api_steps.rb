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

When /^I submit an API upload request with the following parameters as user "([^"]*)"$/ do |email, table|
  params = Hash[*table.raw.flatten]

  file = Rack::Test::UploadedFile.new(params['file'], "application/octet-stream")
  experiment = Experiment.find_by_name!(params['experiment'])
  type = params['type']

  user = User.find_by_email!(email)
  post api_create_data_files_path(:format => :json, :auth_token => user.authentication_token), {'file' => file, 'experiment_id' => experiment.id, 'type' => type}
end

