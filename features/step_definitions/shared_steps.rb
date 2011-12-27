Then /^I should see "([^"]*)" table with$/ do |table_id, expected_table|
  actual = find("table##{table_id}").all('tr').map { |row| row.all('th, td').map { |cell| cell.text.strip } }
  expected_table.diff!(actual)
end

Then /^the "([^"]*)" table should have (\d+) rows$/ do |table_id, expected_rows|
  actual = find("table##{table_id}").all('tr').size - 1 #subtract off one for the header
  actual.should eq(expected_rows.to_i)
end

Then /^I should see field "([^"]*)" with value "([^"]*)"$/ do |field, value|
  # this assumes you're using the helper to render the field and therefore have the usual div/label/span setup
  check_displayed_field(field, value)
end

Then /^I should see details displayed$/ do |table|
  # as above, this assumes you're using the helper to render the field and therefore have the usual div/label/span setup
  table.rows.each do |row|
    check_displayed_field(row[0], row[1])
  end
end

def check_displayed_field(label, value)
  fields = all(".rowform").map { |div| div.all('label, span').map { |cell| cell.text.strip } }
  found = false
  fields.each do |row|
    if row[0] == (label + ":")
      row[1].should eq(value)
      found = true
    end
  end

  raise "Didn't find displayed field with label '#{label}'" unless found
end

Then /^I should see button "([^"]*)"$/ do |arg1|
  page.should have_xpath("//input[@value='#{arg1}']")
end

Then /^I should see image "([^"]*)"$/ do |arg1|
  page.should have_xpath("//img[contains(@src, #{arg1})]")
end

Then /^I should not see button "([^"]*)"$/ do |arg1|
  page.should have_no_xpath("//input[@value='#{arg1}']")
end

Then /^I should see button "([^"]*)" within "([^\"]*)"$/ do |button, scope|
  with_scope(scope) do
    page.should have_xpath("//input[@value='#{button}']")
  end
end

Then /^I should not see button "([^"]*)" within "([^\"]*)"$/ do |button, scope|
  with_scope(scope) do
    page.should have_no_xpath("//input[@value='#{button}']")
  end
end

Then /^I should get a security error "([^"]*)"$/ do |message|
  page.should have_content(message)
  current_path = URI.parse(current_url).path
  current_path.should == path_to("the home page")
end

Then /^I should see link "([^"]*)"$/ do |text|
  page.should have_link(text)
end

Then /^I should not see link "([^"]*)"$/ do |text|
  page.should_not have_link(text)
end

Then /^I should see link "([^\"]*)" within "([^\"]*)"$/ do |text, scope|
  with_scope(scope) do
    page.should have_link(text)
  end
end

Then /^I should not see link "([^\"]*)" within "([^\"]*)"$/ do |text, scope|
  with_scope(scope) do
    page.should_not have_link(text)
  end
end

When /^(?:|I )deselect "([^"]*)" from "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    unselect(row[1], :from => row[0])
  end
end

When /^I select$/ do |table|
  table.hashes.each do |hash|
    When "I select \"#{hash[:value]}\" from \"#{hash[:field]}\""
  end
end

When /^I fill in$/ do |table|
  table.hashes.each do |hash|
    When "I fill in \"#{hash[:field]}\" with \"#{hash[:value]}\""
  end
end

# can be helpful for @javascript features in lieu of "show me the page
Then /^pause$/ do
  puts "Press Enter to continue"
  STDIN.getc
end
