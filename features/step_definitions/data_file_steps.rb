Given /^I have data files$/ do |table|
  table.hashes.each do |attributes|
    email = attributes.delete('uploaded_by')
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

When /^I upload "([^"]*)" through the applet$/ do |filename|
  #post to the upload controller just like the applet would
  user = User.first
  user.reset_authentication_token!
  token = user.authentication_token
  post_path = data_files_url(:format => :json, :auth_token => token)
  file = Rack::Test::UploadedFile.new("#{Rails.root}/samples/#{filename}", "application/octet-stream")
  response = post post_path, {"file_1" => file, "dirStruct" => "[{\"file_1\":\"#{filename}\"}]", "destDir"=>"/"}
  response.status.should eq(200)
  DataFile.count.should_not eq(0)
end

When /^I attempt to upload "([^"]*)" through the applet without an auth token I should get an error$/ do |filename|
  #post to the upload controller just like the applet would
  post_path = data_files_url(:format => :json, :auth_token => "blah")
  file = Rack::Test::UploadedFile.new("#{Rails.root}/samples/#{filename}", "application/octet-stream")
  response = post post_path, {"file_1" => file, "dirStruct" => "[{\"file_1\":\"#{filename}\"}]", "destDir"=>"/"}
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

When /^I do a date search for data files with date "([^"]*)"$/ do |date|
  visit path_to("the list data files page")
  fill_in "Date", :with => date
  click_button "Search"
end

