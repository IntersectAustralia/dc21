Given /^I have the following system configuration$/ do |table|
  SystemConfiguration.instance.update_attributes(table.hashes.first)
end


Then /^the system configuration should have$/ do |table|
  # as above, this assumes you're using the helper to render the field and therefore have the usual div/label/span setup
  table.raw.each do |row|
    SystemConfiguration.instance.send(row[0]).eql?(row[1]).should be_true
  end
end

Given /^I have access groups$/ do |table|
  table.hashes.each do |attributes|
    if attributes.include? ("primary_user")
      primary_user_email = attributes.delete("primary_user")
      primary_user = User.find_by_email(primary_user_email)
      Factory(:access_group, attributes.merge(:primary_user => primary_user))
    else
      Factory(:access_group, attributes)
    end
  end
end