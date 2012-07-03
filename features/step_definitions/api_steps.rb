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
  post_params[:tag_names] = params['tag_names'] unless params['tag_names'].blank?

  post_params[:type] = params['type']
  post_params[:description] = params['description'] if params['description']

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

  actual['messages'].should eq(expected_errors)
end

Then /^I should get a JSON response with filename "([^"]*)" and type "([^"]*)" with the success message$/ do |filename, type|
  require 'json'
  actual = JSON.parse(last_response.body)

  actual['file_id'].should eq(DataFile.last.id)
  actual['file_name'].should eq(filename)
  actual['file_type'].should eq(type)
  actual['messages'].should eq(['File uploaded successfully.'])
end


When /^I should get a JSON response with filename "([^"]*)" and type "([^"]*)" with messages "([^"]*)"$/ do |filename, type, message_codes|
  require 'json'
  actual = JSON.parse(last_response.body)

  actual['file_id'].should eq(DataFile.last.id)
  actual['file_name'].should eq(filename)
  actual['file_type'].should eq(type)

  messages = actual['messages']
  expected_messages = message_codes.split(",")

  messages.size.should eq(expected_messages.size), "Expected #{expected_messages.size} messages, found #{messages.size}. Messages were #{messages}."

  if expected_messages.include?("success")
    messages.include?("File uploaded successfully.").should be_true, "Expected success message to be present, found #{messages}."
  end
  if expected_messages.include?("renamed")
    messages.include?("A file already existed with the same name. File has been renamed.").should be_true, "Expected rename message to be present, found #{messages}."
  end
  if expected_messages.include?("badoverlap")
    messages.join(" ").include?("File cannot safely replace existing files. File has been saved with type ERROR.").should be_true, "Expected bad overlap message to be present, found #{messages}."
  end
  if expected_messages.include?("goodoverlap")
    messages.join(" ").include?("The file replaced one or more other files with similar data. Replaced files: ").should be_true, "Expected good overlap message to be present, found #{messages}."
  end

end

When /^I make a request for the explore data page with the API token for "([^"]*)"$/ do |email|
  user = User.find_by_email!(email)
  get data_files_path(:auth_token => user.authentication_token, :format => :json)
end
