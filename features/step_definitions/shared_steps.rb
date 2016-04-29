Then /^I should see "([^"]*)" table with$/ do |table_id, expected_table|
  actual = find("table##{table_id}").all('tr').map { |row| row.all('th, td').map { |cell| cell.text.strip } }

  chatty_diff_table!(expected_table, actual)
end

Then /^I should see only these rows in "([^"]*)" table$/ do |table_id, expected_table|
  actual = find("table##{table_id}").all('tr').map { |row| row.all('th, td').map { |cell| cell.text.strip } }
  chatty_diff_table!(expected_table, actual, :missing_col => false)
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
  table.raw.each do |row|
    check_displayed_field(row[0], row[1], row[2])
  end
end

def check_displayed_field(label, value, ordered=nil)
  fields = all(".control-group").map { |div| div.all('label, div').map { |cell| cell.text.strip } }
  found = false
  fields.each do |row|
    if row[0] == (label + ":")
      if ordered.eql?("no")
        (row[1].split(/\n+/) - value.split(/\n+/)).should be_empty
      else
        row[1].gsub(/\n+/, "\n").should eq(value.gsub(/\n+/, "\n"))
      end
      found = true
    end
  end

  raise "Didn't find displayed field with label '#{label}'" unless found
end

Then /^(?:|I )should see the following:$/ do |fields|
  fields.raw.each do |name, value|
    field = find_field("#{name}")
    if field.value != value
      raise "Field '#{name}' contains value '#{field.value}' which does not match the expected value '#{value}'"
    end
  end
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


Then /^I should see element with id "([^"]*)"$/ do |arg1|
  page.should have_xpath("//*[@id='#{arg1}']")
end

Then /^I should not see element with id "([^"]*)"$/ do |arg1|
  page.should have_no_xpath("//*[@id='#{arg1}']")
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

# can be helpful for @javascript features in lieu of "show me the page
Then /^pause$/ do
  puts "Press Enter to continue"
  STDIN.getc
end

#Then /^"([^\"]*)" should be visible$/ do |locator|
#  selenium.is_visible(locator).should be_true
#end
#
#Then /^"([^\"]*)" should not be visible$/ do |locator|
#  selenium.is_visible(locator).should_not be_true
#end

##http://makandra.com/notes/1049-check-that-a-page-element-is-not-visible-with-selenium
#Then /^"([^\"]+)" should not be visible$/ do |text|
#  paths = [
#    "//*[@class='hidden']/*[contains(.,'#{text}')]",
#    "//*[@class='invisible']/*[contains(.,'#{text}')]",
#    "//*[@style='display: none;']/*[contains(.,'#{text}')]"
#  ]
#  xpath = paths.join '|'
#  page.should have_xpath(xpath)
#end
#Then /^All checkboxes in "([^"]*)" are checked$/ do |form|
#  within(:xpath, "//form[@name='#{form}']") do
#    page.should have_xpath('//input[@type="checkbox"]/@Checked')
#  end
#end

Then /^the "([^"]*)" select should contain$/ do |label, table|
  field = find_field(label)
  options = field.all("option")
  actual_options = options.collect(&:text)
  expected_options = table.raw.collect { |row| row[0] }
  actual_options.should eq(expected_options)
end

Then /^"([^"]*)" should be selected in the "([^"]*)" select$/ do |expected_option, select_label|
  field = find_field(select_label)
  options = field.all("option[selected]").collect(&:text)
  options.include?(expected_option).should be_true
end

Then /^nothing should be selected in the "([^"]*)" select$/ do |select_label|
  field = find_field(select_label)
  option = field.should_not have_css("option[selected]")
end

def chatty_diff_table!(expected_table, actual, opts={})
  begin
    expected_table.diff!(actual, opts)
  rescue Cucumber::Ast::Table::Different
    puts "Tables were as follows:"
    puts expected_table
    raise
  end
end

When /^I sleep briefly$/ do
  sleep(0.5)
end

Then /^I take a screenshot called "([^"]*)"$/ do |name|
  # only works when using selenium, probably should check and throw an error if not
  page.driver.browser.save_screenshot("screenshot-#{name}.png")
end

When /^I wait for MINT server$/ do
  sleep(2)
end

When /^I wait for (\d+) seconds$/ do |num|
  sleep(num.to_i)
end

When /^I choose "(.*?)" in the select2 menu$/ do |value|
  page.find('.select2-result-label', text: value).click
end

When /^I remove "([^"]*)" from the select2 field/ do |label_text|
  selector = page.find('li', :text => label_text)
  selector.find('.select2-search-choice-close').click
end

When /^I check select2 field "([^"]*)" updated value to "([^"]*)"$/ do |name, value|
  field = page.find("##{name}")
  select2_check value, field
end

def select2_check(new_value, field)
  i = 0
  while i < 10 # times out after 5s
    if field.value == new_value
      return
    else
      sleep(0.5)
    end
    i += 1
  end
end

Then /^I should see select2 field "([^"]*)" with value "([^"]*)"$/ do |name, value|
  field = page.find("##{name}")
  field.value.should eq value
end

Then /^I should see select2 field "([^"]*)" with array values "([^"]*)"$/ do |name, value|
  field = page.find("##{name}")
  field.value.join(", ").should eq value
end

Then /^I should see select2 field "([^"]*)" is empty$/ do |name|
  field = page.find("##{name}")
  field.value.should be_empty
end

Then /^I should see the choice "([^"]*)" in the select2 menu$/ do |value|
  field = page.find(".select2-result-label", text: value)
  field.should_not be_nil
end

Then /^I should not see the choice "([^"]*)" in the select2 menu$/ do |value|
  page.should have_no_xpath("//*[@class='select2-result-label' and text()='#{value}']")
end

Then /^I should see no matches found in the select2 field$/ do
  field = page.find("#select2-drop")
  field.text.strip.should eq "No matches found"
end

Then /^file "([^"]*)" should have labels "([^"]*)"$/ do |file, labels|
  file = DataFile.find_by_filename!(file)
  file.labels.pluck(:name).sort.should eq(labels.split("|").sort)
end

Then /^file "([^"]*)" should have (\d+) labels/ do |file, count|
  file = DataFile.find_by_filename!(file)
  file.labels.count.should eq(count.to_i)
end

Given /^I have labels (.+)$/ do |label_names|
  label_names.split(', ').each do |label_name|
    Factory(:label, :name => label_name)
  end
end

Then /^file "([^"]*)" should have (\d+) contributors/ do |file, count|
  file = DataFile.find_by_filename!(file)
  file.contributors.count.should eq(count.to_i)
end

Given /^I have contributors (.+)$/ do |contributor_names|
  contributor_names.split(', ').each do |contributor_name|
    Factory(:contributor, :name => contributor_name)
  end
end

