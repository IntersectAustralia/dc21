Given /^I have data files$/ do |table|
  table.hashes.each do |attributes|
    email = attributes.delete('uploaded_by')
    if attributes['format'] == ''
      attributes['format'] = nil
    end
    if attributes['file_processing_status'] == ''
      attributes['file_processing_status'] = nil
    end
    exp = attributes.delete('experiment')
    unless exp.blank?
      if exp == "Other"
        attributes["experiment_id"] = "-1"
      else
        experiment = Experiment.find_by_name(exp)
        experiment = Factory(:experiment, :name => exp) unless experiment
        attributes["experiment_id"] = experiment.id
      end
    end
    if email
      user = User.find_by_email(email)
      unless user
        user = Factory(:user, :email => email)
      end
      attributes[:created_by] = user
    end
    tag_csv = attributes.delete('tags')

    df = Factory(:data_file, attributes)

    unless tag_csv.blank?
      tags = tag_csv.split(",").collect { |tag| tag.strip }
      tag_ids = Tag.where(:name => tags).collect(&:id)
      df.tag_ids = tag_ids
    end

  end
end

And /^I follow the view link for data file "([^"]*)"$/ do |filename|
  click_link(filename)
end

Given /^I edit data file "([^"]*)"$/ do |filename|
  click_link(filename)
  click_link "Edit Metadata"
end

When /^I have uploaded "([^"]*)"$/ do |filename|
  user = User.first
  create_data_file filename, user
end

When /^I have uploaded "([^"]*)" as "([^"]*)"$/ do |filename, user_email|
  user = User.find_by_email user_email
  create_data_file filename, user
end

Given /^I have uploaded "([^"]*)" with type "([^"]*)"$/ do |filename, type|
  create_data_file(filename, User.first, type)
end

When /^I have uploaded "([^"]*)" as "([^"]*)" with type "([^"]*)"$/ do |filename, user_email, type|
  user = User.find_by_email user_email
  create_data_file filename, user, type
end

Given /^I have uploaded "([^"]*)" with type "([^"]*)" and description "([^"]*)" and experiment "([^"]*)"$/ do |filename, type, desc, exp|
  create_data_file filename, User.first, type, desc, Experiment.find_by_name!(exp)
end

When /^I attempt to upload "([^"]*)" directly I should get an error$/ do |file_name|
  post_path = data_files_path
  file_path = "#{Rails.root}/samples/#{file_name}"
  raise "Can't find test file: #{file_name}" unless File.exists?(file_path)
  file = Rack::Test::UploadedFile.new(file_path, "application/octet-stream")
  result = post post_path, {"file" => file}
  result.status.should eq(302)
  result.headers["Location"].should =~ /users\/sign_in/
end

Then /^I should get a file with name "([^"]*)" and content type "([^"]*)"$/ do |name, type|
  page.response_headers['Content-Type'].should == type
  page.response_headers['Content-Disposition'].should include("filename=\"#{name}\"")
  page.response_headers['Content-Disposition'].should include("attachment")
end

Then /^the file should contain "([^"]*)"$/ do |expected|
  actual = page.source.strip
  expected.strip.should eq(actual)
end

When /^I do a date search for data files with dates "([^"]*)" and "([^"]*)"$/ do |from, to|
  visit path_to("the list data files page")
  find("#date").click
  fill_in "From Date:", :with => from
  fill_in "To Date:", :with => to
  click_button "Update Search Results"
end

When /^I do a date search for data files with upload dates "([^"]*)" and "([^"]*)"$/ do |from, to|
  visit path_to("the list data files page")
  find("#upload_date").click
  fill_in "upload_from_date", :with => from
  fill_in "upload_to_date", :with => to
  click_button "Update Search Results"
end

When /^I fill in date search details between "([^"]*)" and "([^"]*)"$/ do |from, to|
  fill_in "From Date:", :with => from
  fill_in "To Date:", :with => to
end


Given /^file "([^"]*)" has metadata item "([^"]*)" with value "([^"]*)"$/ do |name, key, value|
  file = DataFile.find_by_filename(name)
  file.metadata_items.create!(:key => key, :value => value)
end

Given /^file "(.*)" has the following metadata$/ do |filename, table|
  file = DataFile.find_by_filename!(filename)

  table.hashes.each do |hsh|
    key = hsh['key']
    value = hsh['value']

    file.metadata_items.create!(:key => key, :value => value)
  end
end

Then /^I should see facility checkboxes$/ do |table|
  labels = find(".facility").all("label").map { |label| label.text.strip }
  expected_labels = table.raw.collect { |row| row[0] }
  labels.should eq(expected_labels)
end

Then /^I should see column checkboxes$/ do |table|
  labels = all(".variable_group").collect do |group|
    parent = group.find("label.variable_parent").text.strip
    children = group.all("label.variable_child").map { |label| label.text.strip }
    [parent, children]
  end
  expected_parents_and_children = table.raw.collect { |row| [row[0], row[1].split(",").collect(&:strip)] }
  labels.should eq(expected_parents_and_children)
end

When /^I check the checkbox for "([^"]*)"$/ do |filename|
  file = DataFile.find_by_filename(filename)
  check("download_checkbox_#{file.id}")
end

Then /^I should see the build custom download page with dates populated with "([^"]*)" and "([^"]*)"$/ do |from, to|
  'Then I should see "Include all data"'
  'And I should see "Only include data in the following range"'
  "And the \"From Date:\" field should contain \"#{from}\""
  "And the \"To Date:\" field should contain \"#{to}\""
end

When /^I delete the file "([^"]*)" added by "([^"]*)"$/ do |filename, email|
  user = User.find_by_email email
  file = DataFile.find_by_filename_and_created_by_id filename, user.id
  file.destroy
end

When /^I select "([^"]*)" from the select box for "([^"]*)"$/ do |option, filename|
  file = DataFile.find_by_filename(filename)
  field = "data_files_#{file.id}_file_processing_status"
  select(option, :from => field)
end

When /^I edit the File Type to "([^"]*)"$/ do |option|
  field = "data_file_file_processing_status"
  select(option, :from => field)
end

When /^I edit the Experiment to "([^"]*)"$/ do |option|
  field = "data_file_experiment_id"
  select(option, :from => field)
end

When /^I fill in "([^"]*)" with "([^"]*)" for "([^"]*)"$/ do |field, value, filename|
  file = DataFile.find_by_filename(filename)

  augmented_field = "data_files_#{file.id}_#{field}"
  fill_in(augmented_field, :with => value)
end

When /^I visit the delete url for "([^"]*)"$/ do |filename|
  file = DataFile.find_by_filename filename
  visit_path data_file_path(file), :delete
end

Then /^I should see postprocess error "(.*)" for "(.*)"$/ do |error_message, filename|
  df = DataFile.find_by_filename!(filename)
  selector = "#datafile_#{df.id}>td.formerror"
  field = find(selector)
  field.should have_content error_message
end

Then /^the experiment select should contain$/ do |table|
  field = find_field("Experiment")
  groups = field.all("optgroup")

  actual_options = []
  groups.each do |group|
    options = group.all("option").collect(&:text)
    actual_options << [group[:label], options]
  end

  expected_options = table.raw.collect { |row| [row[0], row[1].split(",").collect { |i| i.strip }] }
  actual_options.should eq(expected_options)
end

When /^I select "([^"]*)" as the experiment for "([^"]*)"$/ do |experiment, file|
  data_file = DataFile.find_by_filename!(file)
  select_id = "data_files_#{data_file.id}_experiment_id"
  select experiment, :from => select_id
end


Then /^"([^"]*)" should be selected in the experiment select for "([^"]*)"$/ do |expected_option, file|
  data_file = DataFile.find_by_filename!(file)
  select_id = "data_files_#{data_file.id}_experiment_id"

  field = find_field(select_id)
  option = field.find("option[selected]")
  option.text.should eq(expected_option)
end

When /^(?:|I )select "([^"]*)" to upload$/ do |path|
  files = path.split(",").collect { |filename| File.expand_path(filename.strip) }.join(",")
  locator = "Select file(s)"
  msg = "cannot attach file, no file field with id, name, or label '#{locator}' found"
  find(:xpath, XPath::HTML.file_field(locator), :message => msg).set(files)
end

When /^(?:|I )select "([^"]*)" to upload with "([^"]*)"$/ do |path, locator|
  files = path.split(",").collect { |filename| File.expand_path(filename.strip) }.join(",")

  #msg = "cannot attach file, no file field with id, name, or label '#{locator}' found"
  #find(:xpath, XPath::HTML.file_field(locator), :message => msg).set(files)

  page.attach_file(locator, files.first)
end

Then /^the uploaded files display should include "([^"]*)" with file type "([^"]*)"$/ do |filename, type|
  with_scope("the file area for '#{filename}'") do
    page.should have_content(filename)
    page.should have_content("Type: #{type}")
  end
end

Then /^the uploaded files display should include "([^"]*)" with description "([^"]*)"$/ do |filename, desc|
  with_scope("the file area for '#{filename}'") do
    page.should have_content(filename)
    field = find_field("Description")
    field.text.should eq(desc)
  end
end

Then /^the uploaded files display should include "([^"]*)" with tags "([^"]*)"$/ do |filename, tags|
  with_scope("the file area for '#{filename}'") do
    tags.split(",").each do |tag|
      field_checked = find_field(tag.strip)['checked']
      field_checked.should be_true
    end
  end
end

Then /^the uploaded files display should include "([^"]*)" with experiment "([^"]*)"$/ do |filename, experiment|
  with_scope("the file area for '#{filename}'") do
    page.should have_content(filename)
    field = find_field("Experiment")
    field.find("option[selected]").text.should eq(experiment)
  end
end

Then /^the uploaded files display should include "([^"]*)" with messages "([^"]*)"$/ do |filename, message_codes|
  with_scope("the file area for '#{filename}'") do
    page.should have_content(filename)
    messages = all("ul li.alert").collect(&:text)
    expected_messages = message_codes.split(",")

    messages.size.should eq(expected_messages.size), "Expected #{expected_messages.size} messages, found #{messages.size}. Messages were #{messages}."

    if expected_messages.include?("success")
      page.should have_content("File uploaded successfully")
    end
    if expected_messages.include?("renamed")
      page.should have_content("A file already existed with the same name. File has been renamed.")
    end
    if expected_messages.include?("badoverlap")
      page.should have_content("File cannot safely replace existing files. File has been saved with type ERROR.")
    end
    if expected_messages.include?("goodoverlap")
      page.should have_content("The file replaced one or more other files with similar data. Replaced files: ")
    end
  end
end


Then /^the most recent file should have name "([^"]*)"$/ do |name|
  DataFile.last.filename.should eq(name)
end

Then /^file "([^"]*)" should have type "([^"]*)"$/ do |filename, type|
  DataFile.find_by_filename!(filename).file_processing_status.should eq(type)
end

Then /^file "([^"]*)" should have description "([^"]*)"$/ do |filename, desc|
  DataFile.find_by_filename!(filename).file_processing_description.should eq(desc)
end

Then /^file "([^"]*)" should have experiment "([^"]*)"$/ do |filename, experiment|
  DataFile.find_by_filename!(filename).experiment_name.should eq(experiment)
end

Given /^I upload "([^"]*)" with type "([^"]*)" and description "([^"]*)" and experiment "([^"]*)"$/ do |file, type, description, experiment|
  upload(file, type, description, experiment, "")
end

Given /^I upload "([^"]*)" with type "([^"]*)" and description "([^"]*)" and experiment "([^"]*)" and tags "([^"]*)"$/ do |file, type, description, experiment, tags|
  upload(file, type, description, experiment, tags)
end

Then /^I should see tag checkboxes$/ do |table|
  expected = table.raw.collect { |row| row[0] }
  actual = find("#tags").all("input")
  actual.count.should eq(expected.size)
  expected.each do |expected_tag|
    with_scope('"#tags"') do
      page.should have_content(expected_tag)
    end
  end
end

When /^I expand "([^"]*)"$/ do |variable|
  click_link("expand_#{variable.parameterize("_")}")
end

When /^I collapse "([^"]*)"$/ do |variable|
  click_link("expand_#{variable.parameterize("_")}")
end


When /^I expand all the mapped columns$/ do
  all(".expand_variable").each { |link| link.click }
end

private

def create_data_file(filename, user, type=DataFile::STATUS_RAW, description="desc", experiment=nil)
  attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], user, FileTypeDeterminer.new, MetadataExtractor.new)

  path = Rails.root.join('samples', filename).to_s
  file = Rack::Test::UploadedFile.new(path, "application/octet-stream")
  experiment = (Experiment.first || Factory(:experiment)) unless experiment
  attachment_builder.build(file, experiment.id, type, "desc")
end


Then /^there should be (.*) files in the system$/ do |resulting_file_count|
  DataFile.count.should eq(resulting_file_count.to_i)
end

Then /^I should see "([^"]*)" for file "([^"]*)"$/ do |field, file|
  file_obj = DataFile.find_by_filename(file)
  field_id = "file_#{file_obj.id}_#{field.downcase.gsub(/\s/, '_')}"
  step "I should see element with id \"#{field_id}\""

end

Then /^I should not see "([^"]*)" for file "([^"]*)"$/ do |field, file|
  file_obj = DataFile.find_by_filename(file)
  field_id = "file_#{file_obj.id}_#{field.downcase.gsub(/\s/, '_')}"
  step "I should not see element with id \"#{field_id}\""

end

def upload(file, type, description, experiment, tags)
  visit(path_to("the upload page"))
  select type, :from => "File type"
  select experiment, :from => "Experiment"
  fill_in "Description", :with => description
  attach_file("Select file(s)", File.expand_path(file))
  tags.split(",").each do |tag|
    check(tag) unless tag.blank?
  end
  click_button "Upload"

end

When /^I have set the dates of "([^"]*)" as "([^"]*)" to "([^"]*)"$/ do |filename, start, end_date|
  data_file = DataFile.find_by_filename!(filename)
  data_file.start_time = start
  data_file.end_time = end_date
  data_file.save!
end

Then /^file "([^"]*)" should have automatically extracted metadata$/ do |filename|
  data_file = DataFile.find_by_filename!(filename)
  data_file.start_time.should_not be_nil
  data_file.end_time.should_not be_nil
  data_file.metadata_items.should_not be_empty
end

When /^I check file "([^"]*)"$/ do |name|
  data_file = DataFile.find_by_filename(name)
  checkbox_id = "download_checkbox_#{data_file.id}"
  check(checkbox_id)
end

When /^I uncheck file "([^"]*)"$/ do |name|
  data_file = DataFile.find_by_filename(name)
  checkbox_id = "download_checkbox_#{data_file.id}"
  uncheck(checkbox_id)
end

Then /^file "([^"]*)" should be checked$/ do |name|
  data_file = DataFile.find_by_filename(name)
  checkbox_id = "download_checkbox_#{data_file.id}"
  field_checked = find_field(checkbox_id)['checked']
  field_checked.should be_true
end

Then /^file "([^"]*)" should be unchecked$/ do |name|
  data_file = DataFile.find_by_filename(name)
  checkbox_id = "download_checkbox_#{data_file.id}"
  field_checked = find_field(checkbox_id)['checked']
  field_checked.should be_false
end

Then /^I should see the add to cart link for ([^"]*)$/ do |name|
  data_file = DataFile.find_by_filename(name)
  link_id = "add_cart_item_#{data_file.id}"
  page.should have_link(link_id)
end

When /^I add ([^"]*) to the cart$/ do |name|
  data_file = DataFile.find_by_filename(name)
  link_id = "add_cart_item_#{data_file.id}"
  link = find_link(link_id)
  link.click
  wait_until do
    page.evaluate_script('$.active') == 0
  end
end

When /^I remove ([^"]*) from the cart$/ do |name|
  data_file = DataFile.find_by_filename(name)
  cart_item = data_file.cart_items.first
  click_link("remove_from_cart_#{cart_item.id}")
end


# rack-test compatible version of 'add to cart' that doesn't require javascript (selenium)
When /^I add "([^"]*)" to the cart$/ do |name|
  data_file = DataFile.find_by_filename(name)
  click_link("add_cart_item_#{data_file.id}")
end


And /^I should not see the add to cart link for ([^"]*)$/ do |name|
  data_file = DataFile.find_by_filename(name)
  link_id = "add_cart_item_#{data_file.id}"
  page.should_not have_link(link_id)
end

When /^I should not see the add all to cart link$/ do
  page.should_not have_link("Add All")
end

When /^I wait for the page$/ do
  wait_until do
    page.evaluate_script('$.active') == 0
  end
end

When /^the add to cart link for ([^"]*) should be disabled$/ do |name|
  data_file = DataFile.find_by_filename(name)
  page.should_not have_link("add_cart_item_#{data_file.id}")
end


When /^the add to cart link for ([^"]*) should not be disabled$/ do |name|
  data_file = DataFile.find_by_filename(name)
  link_id = "add_cart_item_#{data_file.id}"
  page.should have_link(link_id)
end
