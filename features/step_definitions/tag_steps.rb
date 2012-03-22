Given /^I have tags$/ do |table|
  table.hashes.each { |attrs| Factory(:tag, attrs) }
end

Then /^file "([^"]*)" should have tags "([^"]*)"$/ do |file, tags|
  file = DataFile.find_by_filename!(file)
  file.tags.collect(&:name).sort.should eq(tags.split(",").sort)
end
