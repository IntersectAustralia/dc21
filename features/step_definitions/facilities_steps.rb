Given /^I have facilities$/ do |table|
  table.hashes.each do |attributes|
    Factory(:facility, attributes)
  end
end

When /^I follow the view link for facility "([^"]*)"$/ do |facility_name|
  facility = Facility.find_by_name(facility_name)
  click_link("view_#{facility.id}")
end
When /^I add the following contacts:$/ do |table|
  # table is a  | email (string)   | primary (bool)   |
  table.hashes.each do | contact |
    step "I select \"#{contact['email']}\" from \"contacts_select\""
    step "I follow \"Add\""
    if contact['primary'].to_bool
      user = User.find_by_email contact['email']
      step "I choose \"contact_primary_#{user.id}\""
    end
  end

end