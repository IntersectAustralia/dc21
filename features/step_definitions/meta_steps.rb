Given /^I upload "([^"]*)"$/ do |filename|
  step "I am on the upload page"
  step "I have uploaded \"#{filename}\""
  step "I follow \"Next\""
end

Given /^I fill in the processing metadata fields for the following files$/ do |table|

  table.hashes.each do |hash|
    step "I select \"#{hash['status']}\" from the select box for \"#{hash['filename']}\""
    step "I fill in \"file_processing_description\" with \"#{hash['description']}\" for \"#{hash['filename']}\""
  end

end

Given /^The processing metadata is set for files as follows:$/ do |table|
  step 'I am on the set data file status page'
  step 'I fill in the processing metadata fields for the following files', table
  step 'I press "Done"'
end


Given /^pending$/ do
  pending # express the regexp above with the code you wish you had
end
