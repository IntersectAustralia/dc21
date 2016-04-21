Then /^file "([^"]*)" should have contributors "([^"]*)"$/ do |file, tags|
  file = DataFile.find_by_filename!(file)
  file.contributors.pluck(:name).sort.should eq(tags.split(",").sort)
end