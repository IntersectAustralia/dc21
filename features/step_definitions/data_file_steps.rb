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