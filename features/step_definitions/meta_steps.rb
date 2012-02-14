Given /^I upload "([^"]*)"$/ do |filename|
 step "I am on the upload page"
 step "I upload \"#{filename}\" through the applet"
 step "I follow \"Next\""
end

Given /^I fill in the processing metadata fields for the following files$/ do |table|

  step "select \"RAW\" from the select box for \"sample1.txt\""
  step "\"description\" with \"Raw sample file\" for \"sample1.txt\""

end