Given /^I have experiments$/ do |table|
  table.hashes.each do |exp|
    Factory(:experiment, exp)
  end
end

When /^I follow the view link for experiment "([^"]*)"$/ do |name|
  experiment = Experiment.find_by_name(name)
  click_link "view_#{experiment.id}"
end

Given /^I have no experiments$/ do
  Experiment.delete_all
end