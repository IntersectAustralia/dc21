When /^I select "([^"]*)" from the primary user select box$/ do |option|
  field = "primary_user_select"
  select(option, :from => field)
end

When /^I select and add "([^"]*)" from the other users select box$/ do |option|
  field = "other_users_select"
  select(option, :from => field)
  click_link("access_group_add_user")
end