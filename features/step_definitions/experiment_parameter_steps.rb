Given /^I have experiment parameters$/ do |table|
  table.hashes.each do |attributes|
    category = ParameterCategory.find_by_name!(attributes.delete("category"))
    sub_category = ParameterSubCategory.find_by_name!(attributes.delete("sub_category"))
    modification = ParameterModification.find_by_name!(attributes.delete("modification"))
    unit_name = attributes.delete("units")
    units = unit_name.blank? ? nil : ParameterUnit.find_by_name!(unit_name)
    experiment = Experiment.find_by_name!(attributes.delete("experiment"))
    Factory(:experiment_parameter, attributes.merge(parameter_category: category, parameter_sub_category: sub_category, parameter_modification: modification, experiment: experiment, parameter_unit: units))
  end
end

Given /^I have no experiment parameters$/ do
  ExperimentParameter.delete_all
end

Then /^I should have (\d+) experiment parameters$/ do |count|
  ExperimentParameter.count.should eq(count.to_i)
end

Given /^I follow the edit link for the experiment parameter for "([^"]*)"$/ do |category|
  experiment_parameter = find_experiment_parameter(category)
  click_link("edit_experiment_parameter_#{experiment_parameter.id}")
end

When /^I follow the delete link for experiment parameter "([^"]*)"$/ do |category|
  experiment_parameter = find_experiment_parameter(category)
  click_link("delete_experiment_parameter_#{experiment_parameter.id}")
end

def find_experiment_parameter(category)
  matching = ExperimentParameter.where(:parameter_category_id => ParameterCategory.find_by_name(category))
  raise "Found more than one experiment parameter for category #{category}. You might need to write a more specific step to handle this." if matching.size > 1
  raise "Didn't find any experiment parameter for category #{category}" if matching.size == 0
  matching.first
end
