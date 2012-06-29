Given /^user "([^"]*)" has an API token$/ do |email|
  user = User.find_by_email!(email)
  user.reset_authentication_token!
end

When /^I submit an API upload request without an API token$/ do
  post api_create_data_files_path(:format => :json)
end

When /^I submit an API upload request with an invalid API token$/ do
  post api_create_data_files_path(:format => :json, :auth_token => 'blah')
end

Then /^I should get a (\d+) response code$/ do |status|
  last_response.status.should == status.to_i
end

When /^I submit an API upload request with the following parameters as user "([^"]*)"$/ do |email, table|
  params = Hash[*table.raw.flatten]

  post_params = {}

  unless params['file'].blank?
    file = Rack::Test::UploadedFile.new(params['file'], "application/octet-stream")
    post_params[:file] = file
  end

  unless params['experiment'].blank?
    experiment = Experiment.find_by_name!(params['experiment'])
    post_params[:experiment_id] = experiment.id
  end

  post_params[:experiment_id] = params['experiment_id'] unless params['experiment_id'].blank?

  post_params[:type] = params['type']

  user = User.find_by_email!(email)
  post api_create_data_files_path(:format => :json, :auth_token => user.authentication_token), post_params
end

When /^I submit an API upload request with an invalid file as user "([^"]*)"$/ do |email|
  user = User.find_by_email!(email)
  post_params = {:type => 'RAW', :experiment_id => Experiment.first.id, :file => 'this is a string not a file'}
  post api_create_data_files_path(:format => :json, :auth_token => user.authentication_token), post_params
end

Then /^I should get a JSON response with errors "([^"]*)"$/ do |errors|
  expected_errors = errors.split(", ")

  require 'json'
  actual = JSON.parse(last_response.body)

  actual['errors'].should eq(expected_errors)
end


