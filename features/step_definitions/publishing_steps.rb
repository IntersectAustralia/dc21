Then /^there should be a published collection record named "([^"]*)" with creator "([^"]*)"$/ do |name, creator|
  pc = PublishedCollection.find_by_name!(name)
  pc.created_by_id.should eq(User.find_by_email!(creator).id)
end

Then /^there should be no published collections$/ do
  PublishedCollection.count.should eq(0)
end

Then /^the RIF\-CS file for the latest published collection should match "([^"]*)"$/ do |file|
  pc = PublishedCollection.last
  expected_contents = File.open(File.join(Rails.root, file)).read
  # do substitution on collection url and root url
  expected_contents.gsub!("$$COLLECTION_URL$$", published_collection_url(pc))
  expected_contents.gsub!("$$ROOT_URL$$", root_url)

  actual_contents = File.open(pc.rif_cs_file_path).read

  # convert XML to hashes so we don't have to do dumb string comparison
  actual_hash = Hash.from_xml(actual_contents)
  expected_hash = Hash.from_xml(expected_contents)

  # remove key and originating source and check them separately, since we don't know the URLs ahead of time
  actual_originating_source = actual_hash['registryObjects']['registryObject'].delete('originatingSource')
  actual_key = actual_hash['registryObjects']['registryObject'].delete('key')

  actual_key.should =~ /^http:\/\/([^\/]*)\/published_collections\/#{pc.id}$/
  actual_originating_source.should =~ /^http:\/\/([^\/]*)\/$/

  expected_hash['registryObjects']['registryObject'].delete('originatingSource')
  expected_hash['registryObjects']['registryObject'].delete('key')

  diff = expected_hash.diff(actual_hash)
  unless diff == {}
    # print the files to make comparison easier
    puts "------------------------------"
    puts "Expected:"
    puts "------------------------------"
    puts expected_contents
    puts "------------------------------"
    puts "Actual:"
    puts "------------------------------"
    puts actual_contents
    puts "------------------------------"
    puts "Diff returned: #{diff}"
    raise "XML files did not match"
  end
end

When /^I perform a GET for the zip file for the latest published collection I should get a zip matching "([^"]*)"$/ do |directory_to_match|
  pc = PublishedCollection.last

  url = published_collection_path(pc, format: :zip)
  response = get url

  compare_zip_to_expected_files(response.body, directory_to_match)
end

Given /^I have a published collection called "([^"]*)"$/ do |name|
  Factory(:published_collection, name: name)
end

When /^I publish these search results as "([^"]*)" with description "([^"]*)"$/ do |name, desc|
  click_link "Publish"
  fill_in "Name", :with => name
  fill_in "Description", :with => desc
  click_button "Confirm"

  current_path = URI.parse(current_url).path
  current_path.should == path_to("the home page")
  page.should have_content("Your collection has been successfully submitted for publishing.")
end