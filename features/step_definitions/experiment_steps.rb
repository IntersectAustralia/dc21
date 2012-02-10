Given /^I have experiments$/ do |table|
  table.hashes.each do |exp|
    Factory(:experiment, exp)
  end
end
