Then /^there should be a published collection record named "([^"]*)" with creator "([^"]*)"$/ do |name, creator|
  pc = PublishedCollection.find_by_name!(name)
  pc.created_by_id.should eq(User.find_by_email!(creator).id)
end

Then /^there should be no published collections$/ do
  PublishedCollection.count.should eq(0)
end

Then /^(?:|I )expect uri-open of "([^"]*)" to return "([^"]*)"/ do |url, html|
  #when calling open(url), always return html other than its actual html
  PackageRifCsWrapper.any_instance.stub(:open).with(url,:allow_redirections => :safe).and_return html
end

Then /^the RIF\-CS file for the latest published collection should match "([^"]*)"$/ do |file|
  pc = Package.last
  expected_contents = File.open(File.join(Rails.root, file)).read
  # do substitution on collection url and root url
  expected_contents.gsub!("$$COLLECTION_URL$$", Rails.application.routes.url_helpers.data_file_path(pc))
  expected_contents.gsub!("$$KEY$$", pc.external_id)
  root_url = "http://#{Capybara.current_session.driver.rack_server.host}:#{Capybara.current_session.driver.rack_server.port}/"
  zip_url = File.join(root_url, Rails.application.routes.url_helpers.download_data_file_path(pc))
  expected_contents.gsub!("$$ROOT_URL$$", root_url)
  expected_contents.gsub!("$$ZIP_URL$$", zip_url)
  expected_contents.gsub!("$$PRIMARY_CONTACT$$", 'researcher')
  expected_contents.gsub!("$$LANG$$", pc.language.iso_code)
  expected_contents.gsub!("$$PHYSICAL_ADDRESS$$", SystemConfiguration.instance.entity)
  expected_contents.gsub!("$$BYTE_SIZE$$", number_to_human_size(pc.file_size))

  actual_contents = File.open("/tmp/dc21-data/published_rif_cs/rif-cs-#{pc.id}.xml").read

  # convert XML to hashes so we don't have to do dumb string comparison
  actual_hash = Hash.from_xml(actual_contents)
  expected_hash = Hash.from_xml(expected_contents)

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
  pc = Package.last

  url = File.join(root_url, Rails.application.routes.url_helpers.download_data_file_path(pc))
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