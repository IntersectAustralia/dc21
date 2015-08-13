Given /^I have the following system configuration$/ do |table|
  vals = table.hashes.first
  lang = vals.delete('language')
  SystemConfiguration.instance.update_attributes(vals)
  if lang
    SystemConfiguration.instance.update_attribute(:language, Language.find_by_language_name(lang))
  end
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
