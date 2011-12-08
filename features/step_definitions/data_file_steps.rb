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
  #user = User.find_by_email(user)
  #user.reset_authentication_token!
  #token = user.authentication_token
  post_path = data_files_url(:format => :json) #, :auth_token => token)
  file = Rack::Test::UploadedFile.new("#{Rails.root}/features/samples/#{filename}", "application/octet-stream")
  post post_path, {"file_1" => file, "dirStruct" => "[{\"file_1\":\"#{filename}\"}]", "destDir"=>"/"}
end

