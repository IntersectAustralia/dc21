Given /^I have the following system configuration$/ do |table|
  SystemConfiguration.instance.update_attributes(table.hashes.first)
end
