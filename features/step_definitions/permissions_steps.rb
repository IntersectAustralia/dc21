Then /^I should get the following security outcomes$/ do |table|
  table.hashes.each do |hash|
    page_to_visit = hash[:page]
    outcome = hash[:outcome]
    message = hash[:message]
    visit path_to(page_to_visit)
    if outcome == "error"
      page.should have_content(message)
      current_path = URI.parse(current_url).path
      current_path.should == path_to("the home page")
    else
      current_path = URI.parse(current_url).path
      current_path.should == path_to(page_to_visit)
    end

  end
end

Then /users should be required to login on (.+)$/ do |page_name|
  visit path_to("the logout page")
  visit path_to(page_name)
  page.should have_content("You need to log in before continuing.")
  current_path = URI.parse(current_url).path
  current_path.should == path_to("the login page")
end
