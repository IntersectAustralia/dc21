Given /^I have experiments$/ do |table|
  table.hashes.each do |exp|
    facility_name = exp.delete("facility")
    facility = if facility_name.blank?
                 Factory(:facility)
               else
                 facility = Facility.find_by_name!(facility_name)
               end

    parent = exp.delete("parent")
    parent_exp = parent.blank? ? nil : Experiment.find_by_name!(parent)
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
  experiment = Experiment.find_by_name!(name)
  visit facility_path(experiment.facility)
  click_view_experiment_link(name)
  click_link "Edit Experiment"
end

Given /^the experiment "([^"]*)" has parent "([^"]*)"$/ do |experiment_name, parent_name|
  experiment = Experiment.find_by_name!(experiment_name)
  parent = Experiment.find_by_name!(parent_name)
  experiment.parent_experiment = parent
  experiment.save!
end

Given /^the experiment "([^"]*)" has access rights "([^"]*)"$/ do |experiment_name, access_rights|
  experiment = Experiment.find_by_name!(experiment_name)
  experiment.update_attribute(:access_rights, access_rights)
end

When /^I add for code "([^"]*)"$/ do |code|
  select code, :from => "FOR codes"
  click_link "Add"
  within("#selected_for_codes") { page.should have_content(code) }
end

When /^I add for code "([^"]*)", "([^"]*)"$/ do |code1, code2|
  select code1, :from => "FOR codes"
  select code2, :from => "for_code_select_2"
  click_link "Add"
  within("#selected_for_codes") { page.should have_content(code2) }
end

When /^I add for code "([^"]*)", "([^"]*)", "([^"]*)"$/ do |code1, code2, code3|
  select code1, :from => "FOR codes"
  select code2, :from => "for_code_select_2"
  select code3, :from => "for_code_select_3"
  click_link "Add"
  within("#selected_for_codes") { page.should have_content(code3) }
end

Then /^I should see for codes$/ do |table|
  expected_codes = table.raw.collect { |row| row[0] }
  actual_codes = get_for_codes_on_page
  actual_codes.should eq(expected_codes)
end

Then /^I should see no for codes$/ do
  get_for_codes_on_page.should be_empty
end

Given /^I have filled in the basic fields on the new experiment page under facility "([^"]*)"$/ do |facility|
  visit facility_path(Facility.find_by_name!(facility))
  click_link "New Experiment"
  fill_in "Name", :with => "My experiment"
  fill_in "Start date", :with => "2012-01-01"
  fill_in "Subject", :with => "My subject"
  select "CC BY: Attribution", :from => "Access rights"
end

Given /^I have filled in no dates on the new experiment page under facility "([^"]*)"$/ do |facility|
  visit facility_path(Facility.find_by_name!(facility))
  click_link "New Experiment"
  fill_in "Name", :with => "My experiment"
  fill_in "Subject", :with => "My subject"
  select "CC BY: Attribution", :from => "Access rights"
end

Given /^I have filled in end date before start date on the new experiment page under facility "([^"]*)"$/ do |facility|
  visit facility_path(Facility.find_by_name!(facility))
  click_link "New Experiment"
  fill_in "Name", :with => "My experiment"
  fill_in "Start date", :with => "2012-02-01"
  fill_in "End date", :with => "2012-01-01"
  fill_in "Subject", :with => "My subject"
  select "CC BY: Attribution", :from => "Access rights"
end

Given /^I have filled in invalid dates on the new experiment page under facility "([^"]*)"$/ do |facility|
  visit facility_path(Facility.find_by_name!(facility))
  click_link "New Experiment"
  fill_in "Name", :with => "My experiment"
  fill_in "Start date", :with => "2012-02-44"
  fill_in "End date", :with => "2012-03-44"
  fill_in "Subject", :with => "My subject"
  select "CC BY: Attribution", :from => "Access rights"
end

Given /^experiment "([^"]*)" has for code "([^"]*)"$/ do |exp, code|
  experiment = Experiment.find_by_name!(exp)
  experiment.experiment_for_codes.create!(:name => code, :url => "blah")
end

Given /^experiment "([^"]*)" has for code "([^"]*)" with url "([^"]*)"$/ do |exp, code, url|
  experiment = Experiment.find_by_name!(exp)
  experiment.experiment_for_codes.create!(:name => code, :url => url)
end

When /^I delete for code "([^"]*)"$/ do |code|
  ok = false
  all("ul#for_codes_list li").each do |item|
    if item.text =~ /#{code}/
      item.find("a").click
      ok = true
    end
  end
  raise "Didn't find FOR code #{code}" unless ok
end

Then /^experiment "([^"]*)" should have for codes$/ do |experiment_name, table|
  experiment = Experiment.find_by_name!(experiment_name)
  expected_codes = table.raw.collect { |row| row[0] }
  actual_codes = experiment.experiment_for_codes.pluck(:name)
  actual_codes.should eq(expected_codes)
end

Then /^experiment "([^"]*)" should have (\d+) for codes$/ do |experiment_name, count|
  experiment = Experiment.find_by_name!(experiment_name)
  actual_count = experiment.experiment_for_codes.count
  actual_count.should eq(count.to_i), "Expected experiment #{experiment_name} to have #{count} FOR codes, found #{actual_count}"
  ExperimentForCode.where("experiment_id is NULL").count.should eq(0) #check that there's no orphans
end

Given /^I have the standard set of experiment parameter lookup values$/ do
  light = ParameterCategory.create!(name: "Light")
  atmosphere = ParameterCategory.create!(name: "Atmosphere")
  temperature = ParameterCategory.create!(name: "Temperature")
  humidity = ParameterCategory.create!(name: "Humidity")

  atmosphere.parameter_sub_categories.create!(name: "Carbon Dioxide")
  atmosphere.parameter_sub_categories.create!(name: "Nitrogen")
  atmosphere.parameter_sub_categories.create!(name: "Oxygen")

  light.parameter_sub_categories.create!(name: "Natural")
  light.parameter_sub_categories.create!(name: "Infrared")
  light.parameter_sub_categories.create!(name: "Ultraviolet")

  temperature.parameter_sub_categories.create!(name: "Air Temperature")
  temperature.parameter_sub_categories.create!(name: "Soil Temperature")

  humidity.parameter_sub_categories.create!(name: "Normal")

  ParameterModification.create!(name: "Above ambient")
  ParameterModification.create!(name: "Below ambient")
  ParameterModification.create!(name: "Absolute target")
  ParameterModification.create!(name: "Excluded")

  ParameterUnit.create!(:name => "PPM")
  ParameterUnit.create!(:name => "Degrees C")
  ParameterUnit.create!(:name => "Lumens")
  ParameterUnit.create!(:name => "Litres")
  ParameterUnit.create!(:name => "Millilitres")

end

def click_view_experiment_link(name)
  experiment = Experiment.find_by_name!(name)
  click_link name
end

def get_for_codes_on_page
  all("ul#for_codes_list li").collect { |item| item.text.gsub("Delete", "").strip }
end

Given /^I have experiment "([^"]*)"$/ do |name|
  Factory(:experiment, name: name)
end

Given /^I have experiment "([^"]*)" which belongs to facility "([^"]*)"$/ do |name, facility|
  Factory(:experiment, name: name, facility: Facility.find_by_code(facility))
end
