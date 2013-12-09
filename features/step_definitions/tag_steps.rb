Given /^I have tag "([^"]*)"$/ do |name|
  Factory(:tag, name: name)
end

Given /^I have tags$/ do |table|
  table.hashes.each { |attrs| Factory(:tag, attrs) }
end

Then /^file "([^"]*)" should have tags "([^"]*)"$/ do |file, tags|
  file = DataFile.find_by_filename!(file)
  file.tags.pluck(:name).sort.should eq(tags.split(",").sort)
end

Then /^file "([^"]*)" should have (\d+) tags$/ do |file, count|
  file = DataFile.find_by_filename!(file)
  file.tags.count.should eq(count.to_i)
end

