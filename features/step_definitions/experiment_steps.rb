Given /^I have experiments$/ do |table|
  table.hashes.each do |exp|
    facility_name = exp.delete("facility")
    facility = Facility.find_by_name(facility_name)
    Factory(:experiment, exp.merge(:facility => facility))
  end
end

When /^I follow the view link for experiment "([^"]*)"$/ do |name|
  click_view_experiment_link(name)
end

Given /^I have no experiments$/ do
  Experiment.delete_all
end

Given /^I edit experiment "([^"]*)"$/ do |name|
  experiment = Experiment.find_by_name(name)
  visit facility_path(experiment.facility)
  click_view_experiment_link(name)
  click_link "Edit Experiment"
end

Given /^the experiment "([^"]*)" has parent "([^"]*)"$/ do |experiment_name, parent_name|
  experiment = Experiment.find_by_name(experiment_name)
  parent = Experiment.find_by_name(parent_name)
  experiment.parent_experiment = parent
  experiment.save!
end


def click_view_experiment_link(name)
  experiment = Experiment.find_by_name(name)
  click_link "view_#{experiment.id}"
end
