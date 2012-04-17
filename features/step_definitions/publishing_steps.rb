Then /^there should be a published collection record named "([^"]*)" with creator "([^"]*)"$/ do |name, creator|
  pc = PublishedCollection.find_by_name!(name)
  pc.created_by_id.should eq(User.find_by_email!(creator).id)
  pending # express the regexp above with the code you wish you had
end

Then /^there should be no published collections$/ do
  PublishedCollection.count.should eq(0)
end

