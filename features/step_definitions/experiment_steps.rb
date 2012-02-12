Given /^I have experiments$/ do |table|
  table.hashes.each do |exp|
    Factory(:experiment, exp)
  end
end

When /^I follow the view link for experiment "([^"]*)"$/ do |name|
  click_view_experiment_link(name)
end

Given /^I have no experiments$/ do
  Experiment.delete_all
end

Given /^I edit experiment "([^"]*)"$/ do |name|
  visit path_to("the experiments page")
  click_view_experiment_link(name)
  click_link "Edit Experiment"
end

def click_view_experiment_link(name)
  experiment = Experiment.find_by_name(name)
  click_link "view_#{experiment.id}"
end