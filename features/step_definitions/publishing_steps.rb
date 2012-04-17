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
  actual_contents = File.open(pc.rif_cs_file_path).read

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
  end
  diff.should == {}
end
