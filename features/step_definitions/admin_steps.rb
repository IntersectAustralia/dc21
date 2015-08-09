Given /^I have the following system configuration$/ do |table|
  SystemConfiguration.instance.update_attributes(table.hashes.first)
end

Given /^I have languages$/ do |table|
  table.hashes.each do |hash|
    Factory(:language, hash)
  end
end

Then /^the system configuration should have$/ do |table|
  # as above, this assumes you're using the helper to render the field and therefore have the usual div/label/span setup
  table.raw.each do |row|
    SystemConfiguration.instance.send(row[0]).eql?(row[1]).should be_true
  end
end
