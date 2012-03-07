Given /^I have data files$/ do |table|
  table.hashes.each do |attributes|
    email = attributes.delete('uploaded_by')
    if attributes['file_processing_status'] == ''
      attributes['file_processing_status'] = nil
    end
    exp = attributes.delete('experiment')
    unless exp.blank?
      if exp == "Other"
        attributes["experiment_id"] = "-1"
      else
        experiment = Experiment.find_by_name(exp)
        experiment = Factory(:experiment) unless experiment
        attributes["experiment_id"] = experiment.id
      end
    end
    if email
      user = User.find_by_email(email)
      unless user
        user = Factory(:user, :email => email)
      end
      attributes[:created_by] = user
    end
    Factory(:data_file, attributes)
  end
end

And /^I follow the view link for data file "([^"]*)"$/ do |filename|
  file = DataFile.find_by_filename(filename)
  click_link("view_#{file.id}")
end

#post to the upload controller just like the applet would
When /^I upload "([^"]*)" through the applet$/ do |filename|
  user = User.first
  do_upload filename, user
end
When /^I upload "([^"]*)" through the applet as "([^"]*)"$/ do |filename, user_email|
  user = User.find_by_email user_email
  do_upload filename, user
end

When /^I attempt to upload "([^"]*)" through the applet without an auth token I should get an error$/ do |filename|
  #post to the upload controller just like the applet would
  post_path = data_files_url(:format => :json, :auth_token => "blah")
  file = Rack::Test::UploadedFile.new("#{Rails.root}/samples/#{filename}", "application/octet-stream")
  response = post post_path, {"file_1" => file, "dirStruct" => "[{\"file_1\":\"#{filename}\"}]", "destDir" => "/"}
  response.status.should eq(401)
end

Then /^I should get a file with name "([^"]*)" and content type "([^"]*)"$/ do |name, type|
  page.response_headers['Content-Type'].should == type
  page.response_headers['Content-Disposition'].should include("filename=\"#{name}\"")
  page.response_headers['Content-Disposition'].should include("attachment")
end

Then /^the file should contain "([^"]*)"$/ do |expected|
  actual = page.source.strip
  expected.strip.should eq(actual)
end

Then /^I should get a download of all data files$/ do
  page.response_headers['Content-Disposition'].should include("filename=\"download_selected.zip\"")
  page.response_headers['Content-Disposition'].should include("attachment")
end

When /^I do a date search for data files with dates "([^"]*)" and "([^"]*)"$/ do |from, to|
  visit path_to("the list data files page")
  #click_link "Search Files"
  fill_in "From Date:", :with => from
  fill_in "To Date:", :with => to
  click_button "Update Search Results"
end

When /^I fill in date search details between "([^"]*)" and "([^"]*)"$/ do |from, to|
  fill_in "From Date:", :with => from
  fill_in "To Date:", :with => to
end


Given /^file "([^"]*)" has metadata item "([^"]*)" with value "([^"]*)"$/ do |name, key, value|
  file = DataFile.find_by_filename(name)
  file.metadata_items.create!(:key => key, :value => value)
end

Given /^file "(.*)" has the following metadata$/ do |filename, table|
  file = DataFile.find_by_filename!(filename)

  table.hashes.each do |hsh|
    key = hsh['key']
    value = hsh['value']

    file.metadata_items.create!(:key => key, :value => value)
  end
end

Then /^I should see facility checkboxes$/ do |table|
  labels = find(".facility").all("label").map { |label| label.text.strip }
  expected_labels = table.raw.collect { |row| row[0] }
  labels.should eq(expected_labels)
end

Then /^I should see variable checkboxes$/ do |table|
  labels = find(".variable").all("label").map { |label| label.text.strip }
  expected_labels = table.raw.collect { |row| row[0] }
  labels.should eq(expected_labels)
end

When /^I check the checkbox for "([^"]*)"$/ do |filename|
  file = DataFile.find_by_filename(filename)
  check("download_checkbox_#{file.id}")
end

Then /^I should see the build custom download page with dates populated with "([^"]*)" and "([^"]*)"$/ do |from, to|
  'Then I should see "Include all data"'
  'And I should see "Only include data in the following range"'
  "And the \"From Date:\" field should contain \"#{from}\""
  "And the \"To Date:\" field should contain \"#{to}\""
end

When /^I delete the file "([^"]*)" added by "([^"]*)"$/ do |filename, email|
  user = User.find_by_email email
  file = DataFile.find_by_filename_and_created_by_id filename, user.id
  file.destroy
end

When /^I select "([^"]*)" from the select box for "([^"]*)"$/ do |option, filename|
  file = DataFile.find_by_filename(filename)
  field = "data_files_#{file.id}_file_processing_status"
  select(option, :from => field)
end

When /^I fill in "([^"]*)" with "([^"]*)" for "([^"]*)"$/ do |field, value, filename|
  file = DataFile.find_by_filename(filename)

  augmented_field = "data_files_#{file.id}_#{field}"
  fill_in(augmented_field, :with => value)
end

When /^I visit the delete url for "([^"]*)"$/ do |filename|
  file = DataFile.find_by_filename filename
  visit_path data_file_path(file), :delete
end

Then /^I should see postprocess error "(.*)" for "(.*)"$/ do |error_message, filename|
  df = DataFile.find_by_filename!(filename)
  selector = "#datafile_#{df.id}>td.formerror"
  field = find(selector)
  field.should have_content error_message
end

Then /^the experiment select for "([^"]*)" should contain$/ do |file, table|
  data_file = DataFile.find_by_filename!(file)
  select_id = "data_files_#{data_file.id}_experiment_id"

  field = find_field(select_id)
  groups = field.all("optgroup")

  actual_options = []
  groups.each do |group|
    options = group.all("option").collect(&:text)
    actual_options << [group[:label], options]
  end

  expected_options = table.raw.collect { |row| [row[0], row[1].split(",").collect{|i| i.strip}] }
  actual_options.should eq(expected_options)
end

When /^I select "([^"]*)" as the experiment for "([^"]*)"$/ do |experiment, file|
  data_file = DataFile.find_by_filename!(file)
  select_id = "data_files_#{data_file.id}_experiment_id"
  select experiment, :from => select_id
end


Then /^"([^"]*)" should be selected in the experiment select for "([^"]*)"$/ do |expected_option, file|
  data_file = DataFile.find_by_filename!(file)
  select_id = "data_files_#{data_file.id}_experiment_id"

  field = find_field(select_id)
  option = field.find("option[selected]")
  option.text.should eq(expected_option)
end

private

def do_upload(filename, user, path=nil)
  user.reset_authentication_token!
  token = user.authentication_token
  post_path = data_files_url(:format => :json, :auth_token => token)
  if path
    path = Rails.root.join('samples', path, filename).to_s
  else
    path = Rails.root.join('samples', filename).to_s
  end
  file = Rack::Test::UploadedFile.new(path, "application/octet-stream")
  response = post post_path, {"file_1" => file, "dirStruct" => "[{\"file_1\":\"#{filename}\"}]", "destDir" => "/"}
  response.status.should eq(200)
  DataFile.count.should_not eq(0)
end

