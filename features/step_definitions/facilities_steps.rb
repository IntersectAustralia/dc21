Given /^I have facilities$/ do |table|
  table.hashes.each do |attributes|
    Factory(:facility, attributes)
  end
end

When /^I follow the view link for facility "([^"]*)"$/ do |facility_name|
  facility = Facility.find_by_name(facility_name)
  click_link("view_#{facility.id}")
end
