Given /^I have experiments$/ do |table|
  table.hashes.each do |exp|
    facility_name = exp.delete("facility")
    facility = Facility.find_by_name(facility_name)

    parent = exp.delete("parent")
    parent_exp = parent.blank? ? nil : Experiment.find_by_name(parent)
    Factory(:experiment, exp.merge(:facility => facility, :parent_experiment => parent_exp))
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

When /^I add for code "([^"]*)"$/ do |code|
  select code, :from => "FOR Code"
  click_link "Add"
  within("#selected_for_codes") { page.should have_content(code) }
end

Then /^I should see for codes$/ do |table|
  expected_codes = table.raw.collect { |row| row[0] }
  actual_codes = all("ul#for_codes li").collect(&:text)
  actual_codes.should eq(expected_codes)
end

Given /^I have filled in the basic fields on the new experiment page under facility "([^"]*)"$/ do |facility|
  visit facility_path(Facility.find_by_name!(facility))
  click_link "New Experiment"
  fill_in "Name", :with => "My experiment"
  fill_in "Start date", :with => "2012-01-01"
  fill_in "Subject", :with => "My subject"
end

def click_view_experiment_link(name)
  experiment = Experiment.find_by_name(name)
  click_link "view_#{experiment.id}"
end

