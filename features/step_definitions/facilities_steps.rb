Given /^I have facilities$/ do |table|
  table.hashes.each do |attributes|
    if attributes.include? ("primary_contact")
      primary_contact_email = attributes.delete("primary_contact")
      primary_contact = User.find_for_authentication(email: primary_contact_email)
      Factory(:facility, attributes.merge(:primary_contact => primary_contact))
    else
      Factory(:facility, attributes)
    end
  end
end

Given /^I have facility "([^"]*)" with code "([^"]*)"$/ do |name, code|
  Factory(:facility, :name => name, :code => code)
end

When /^I follow the view link for facility "([^"]*)"$/ do |facility_name|
  facility = Facility.find_by_name(facility_name)
  click_link("view_#{facility.id}")
end

When /^I add the following contacts:$/ do |table|
  # table is a  | email (string)   | primary (bool)   |
  table.hashes.each do |contact|
    step "I select \"#{contact['email']}\" from \"contacts_select\""
    step "I follow \"Add\""
    if contact['primary'].to_bool
      user = User.find_by_email contact['email']
      step "I choose \"contact_primary_#{user.id}\""
    end
  end
end

When /^I select "([^"]*)" from the primary select box$/ do |option|
  field = "primary_contact_select"
  select(option, :from => field)
end

When /^I select and add "([^"]*)" from the other contacts select box$/ do |option|
  field = "other_contacts_select"
  select(option, :from => field)
  click_link("facility_add_contact")
end
