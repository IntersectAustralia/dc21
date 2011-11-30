Given /^I have data files$/ do |table|
  table.hashes.each do |attributes|
    Factory(:data_file, attributes)
  end
end