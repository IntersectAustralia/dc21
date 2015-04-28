Given /^I have access groups$/ do |table|
  table.hashes.each do |attributes|
    user_list = attributes.delete("users")
    unless user_list.blank?
      attributes["user_ids"] = User.where(email: user_list.split(", ")).collect(&:id)
    end

    if attributes.include? ("primary_user")
      primary_user_email = attributes.delete("primary_user")
      primary_user = User.find_for_authentication(email: primary_user_email)
      Factory(:access_group, attributes.merge(:primary_user => primary_user))
    else
      Factory(:access_group, attributes)
    end
  end
end

When /^I select "([^"]*)" from the primary user select box$/ do |option|
  field = "primary_user_select"
  select(option, :from => field)
end

When /^I select and add "([^"]*)" from the user access groups box$/ do |option|
  field = "user_access_groups"
  select(option, :from => field)
  click_button("Add Access Group")
end

When /^I select and add "([^"]*)" from the other users select box$/ do |option|
  field = "other_users_select"
  select(option, :from => field)
  click_link("access_group_add_user")
end

When /^I add the following users:$/ do |table|
  # table is a  | email (string)   |
  table.hashes.each do |user|
    step "I select and add \"#{user['email']}\" from the other users select box"
  end
  step "I press \"Update\""
end

When /^I follow "delete" for access group "([^"]*)"$/ do |name|
  group = AccessGroup.where(:name => name).first
  click_link_or_button("delete_#{group.id}")
end