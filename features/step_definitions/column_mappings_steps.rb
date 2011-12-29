Given /^I have column mappings$/ do |table|
  table.hashes.each do |attributes|
    Factory(:column_mapping, attributes)
  end
end
