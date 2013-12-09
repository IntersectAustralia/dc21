Given /^user "([^"]*)" has an API token$/ do |email|
  User.all.collect(&:email)
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

  unless params['facility'].blank?
    facility = Facility.find_by_id(params['facility'])
    post_params[:facility_id] = facility.id
  end

  unless params['org_level2'].blank?
    experiment = Experiment.find_by_name!(params['org_level2'])
    post_params[:org_level2_id] = experiment.id
  end

  post_params[:experiment_id] = params['experiment_id'] unless params['experiment_id'].blank?
  post_params[:org_level2_id] = params['org_level2_id'] unless params['org_level2_id'].blank?
  post_params[:tag_names] = params['tag_names'] unless params['tag_names'].blank?
  post_params[:label_names] = params['labels'] unless params['labels'].blank?

  post_params[:type] = params['type']
  post_params[:description] = params['description'] if params['description']

  post_params[:parent_filenames] = params['parent_filenames'].split(",") unless params['parent_filenames'].blank?

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

When /^I make a request for the data download page for "([^"]*)" with an invalid API token$/ do |data|
  get download_data_file_path(:id => DataFile.find_by_filename(data).id, :auth_token => 'blah', :format => :json)
end

When /^I make a request for the data download page for "([^"]*)" without an API token$/ do |data|
  get download_data_file_path(:id => DataFile.find_by_filename(data).id, :format => :json)
end

When /^I perform an API search with the following parameters as user "([^"]*)"$/ do |email, table|
  post_params = Hash[*table.raw.flatten]
  if post_params['facilities']
    facilities = post_params.delete('facilities')
    post_params['facilities'] = Facility.where(name: facilities.split(", ")).collect(&:id)
  end
  if post_params['experiments']
    experiments = post_params.delete('experiments')
    post_params['experiments'] = Experiment.where(name: experiments.split(", ")).collect(&:id)
  end
  if post_params['labels']
    labels = post_params.delete('labels')
    post_params['labels'] = labels.split(", ")
  end
  if post_params['tags']
    tags = post_params.delete('tags')
    post_params['tags'] = Tag.where(name: tags.split(", ")).collect(&:id)
  end
  if post_params['automation_stati']
    automation_stati = post_params.delete('automation_stati')
    post_params['automation_stati'] = automation_stati.split(", ")
  end
  user = User.find_by_email!(email)
  post api_search_data_files_path(:format => :json, :auth_token => user.authentication_token), post_params
end

When /^I perform an API search without an API token$/ do |table|
  post_params = Hash[*table.raw.flatten]
  post api_search_data_files_path(:format => :json), post_params
end

When /^I perform an API search with an invalid API token$/ do |table|
  post_params = Hash[*table.raw.flatten]
  post api_search_data_files_path(:format => :json, :auth_token => 'blah'), post_params
end

When /^I should get a JSON response with$/ do |table|
  actual = JSON.parse(last_response.body)
  actual.size.should eq(table.hashes.size)
  count = 0
  table.hashes.each do |attributes|
    attributes.each do |key, value|
      actual[count][key].should eq(value)
    end
    count += 1
  end
end

When /^I should have file download link for each entry$/ do
  actual = JSON.parse(last_response.body)
  actual.each do |entry|
    entry["url"].should eq(Rails.application.routes.url_helpers.download_data_file_url(entry["file_id"], :host => 'example.org', :format => :json))
  end
end
