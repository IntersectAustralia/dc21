Given /^I have data files$/ do |table|
  table.hashes.each do |attributes|
    attributes.delete('id') if attributes['id'] == ''

    fac = attributes.delete('facility')
    unless fac.blank?
      facility = Facility.find_by_name(fac)
      facility = Factory(:facility, :name => fac) unless facility
    end

    exp = attributes.delete('experiment')
    unless exp.blank?
      experiment = Experiment.find_by_name(exp)
      if facility
        experiment = Factory(:experiment, :name => exp, facility_id: facility.id) unless experiment
      else
        experiment = Factory(:experiment, :name => exp) unless experiment
      end
      attributes["experiment_id"] = experiment.id
    end

    par = attributes.delete('parents')
    unless par.blank?
      attributes["parent_ids"] = DataFile.where(filename: par.split(", ")).collect(&:id)
    end

    chi = attributes.delete('children')
    unless chi.blank?
      attributes["child_ids"] = DataFile.where(filename: chi.split(", ")).collect(&:id)
    end

    exp = attributes.delete('experiment')
    unless exp.blank?
      experiment = Experiment.find_by_name(exp)
      if facility
        experiment = Factory(:experiment, :name => exp, facility_id: facility.id) unless experiment
      else
        experiment = Factory(:experiment, :name => exp) unless experiment
      end
      attributes["experiment_id"] = experiment.id
    end

    email = attributes.delete('uploaded_by')
    if attributes['format'] == ''
      attributes['format'] = nil
    end
    if attributes['file_processing_status'] == ''
      attributes['file_processing_status'] = nil
    elsif attributes['file_processing_status'] == 'PACKAGE'
      attributes['format'] = Package::PACKAGE_FORMAT
    end
    if attributes['transfer_status'] == ''
      attributes['transfer_status'] = nil
    end
    if attributes['uuid'] == ''
      attributes['uuid'] = nil
    end

    if attributes['path']
      new_path = "#{APP_CONFIG['files_root']}/#{attributes['filename']}"
      `cp #{attributes['path']} #{new_path}`
      attributes['path'] = new_path
    end


    if email
      user = User.find_for_authentication(email: email)
      unless user
        user = Factory(:user, :email => email)
      end
      attributes[:created_by] = user
    end
    published_by_email = attributes.delete('published_by')
    if published_by_email
      user = User.find_for_authentication(email: published_by_email)
      unless user
        user = Factory(:user, :email => published_by_email)
      end
      attributes[:published_by] = user
    end unless published_by_email.blank? or published_by_email.nil?

    tag_csv = attributes.delete('tags')
    label_csv = attributes.delete('label_list')
    grant_numbers_csv = attributes.delete('grant_numbers')
    related_websites_csv = attributes.delete('related_websites')
    contributors_csv = attributes.delete('contributors')

    creator = attributes.delete('creator')
    creator_id= (creator.nil? || creator.eql?("")) ? user.id : User.approved.find_by_email(creator).id
    attributes["creator_id"] = creator_id

    if attributes['file_processing_status'] == 'PACKAGE'
      df = Factory(:package, attributes)
    else
      df = Factory(:data_file, attributes)
    end

    unless tag_csv.blank?
      tags = tag_csv.split(",").collect { |tag| tag.strip }
      tag_ids = Tag.where(:name => tags).collect(&:id)
      df.tag_ids = tag_ids
    end

    unless label_csv.blank?
      labels = label_csv.split(",").collect { |label| label.strip }
      labels.map { |label| df.labels << Label.find_or_create_by_name(label) }
    end

    unless contributors_csv.blank?
      contributors = contributors_csv.split(",").collect {|cont| cont.strip}
      contributors.map { |cont| df.contributors << Contributor.find_or_create_by_name(cont) }
    end

    unless grant_numbers_csv.blank?
      grant_numbers = grant_numbers_csv.split(",").collect {|gn| gn.strip}
      grant_numbers.map { |gn| df.grant_numbers << GrantNumber.find_or_create_by_name(gn) }
    end

    unless related_websites_csv.blank?
      related_websites = related_websites_csv.split(",").collect {|rw| rw.strip}
      related_websites.map { |rw| df.related_websites << RelatedWebsite.find_or_create_by_url(rw)}
    end

    if df.is_package?
      `touch #{df.path}`
      dir = df.published ? APP_CONFIG['published_rif_cs_directory'] : APP_CONFIG['unpublished_rif_cs_directory']
      Dir.mkdir(dir) unless Dir.exists?(dir)
      output_location = File.join(dir, "rif-cs-#{df.id}.xml")
      `touch #{output_location}`
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

Given /^I have uploaded "([^"]*)" with parents "([^"]*)"$/ do |filename, parents|
  create_data_file(filename, User.first, "RAW", "desc", nil, parents)
end

Given /^I have uploaded "([^"]*)" as "([^"]*)" with parents "([^"]*)"$/ do |filename, user_email, parents|
  user = User.find_by_email user_email
  create_data_file(filename, user, "RAW", "desc", nil, parents)
end

Given /^I have uploaded "([^"]*)" with parents "([^"]*)" and children "([^"]*)"$/ do |filename, parents, children|
  create_data_file(filename, User.first, "RAW", "desc", nil, parents, children)
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
  if page.response_headers['Content-Disposition']
    page.response_headers['Content-Type'].should == type
    page.response_headers['Content-Disposition'].should include("filename=\"#{name}\"")
    page.response_headers['Content-Disposition'].should include("attachment")
  else
    last_response.headers['Content-Type'].should == type
    last_response.headers['Content-Disposition'].should include("filename=\"#{name}\"")
    last_response.headers['Content-Disposition'].should include("attachment")
  end
end

Then /^the file should contain "([^"]*)"$/ do |expected|
  if page.response_headers['Content-Disposition']
    actual = page.source.strip
  else
    actual = last_response.body.strip
  end
  expected.strip.should eq(actual)
end

When /^I do a date search for data files with dates "([^"]*)" and "([^"]*)"$/ do |from, to|
  visit path_to("the list data files page")
  find("#drop4").click
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
  labels = all(".facility > .facility_group > label").map { |label| label.text.strip }
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
  page.driver.submit :delete, data_file_path(file), {}
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
  msg = "cannot attach file, no file field with id, name, or label '#{locator}' found"
  find(:xpath, XPath::HTML.file_field(locator), :message => msg).set(files)

  #page.attach_file(locator, files.first)
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
    field.text.gsub(/\A\n|\n$/, '').should eq(desc)
  end
end
Then /^the uploaded files display should include "([^"]*)" with labels "([^"]*)"$/ do |filename, labels|
  with_scope("the file area for '#{filename}'") do
    page.should have_content(filename)
    field = find_field("Labels")
    field.value.should eq(labels)
  end
end

Then /^the uploaded files display should include "([^"]*)" with contributors "([^"]*)"$/ do |filename, contributors|
  with_scope("the file area for '#{filename}'") do
    page.should have_content(filename)
    field = find_field("Contributors")
    field.value.should eq(contributors)
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
    if expected_messages.include?("ownership_inherited")
      page.should have_content("The file has inherited ownership and access control metadata from ")
    end

  end
end


Then /^the most recent file should have name "([^"]*)"$/ do |name|
  DataFile.last.filename.should eq(name)
end

Then /^file "([^"]*)" should have type "([^"]*)"$/ do |filename, type|
  base_filename = filename.split("/").last
  DataFile.find_by_filename!(base_filename).file_processing_status.should eq(type)
end

Then /^file "([^"]*)" should be created by "([^"]*)"$/ do |filename, email|
  base_filename = filename.split("/").last
  DataFile.find_by_filename!(base_filename).created_by.email.should eq(email)
end

Then /^file "([^"]*)" should have description "([^"]*)"$/ do |filename, desc|
  DataFile.find_by_filename!(filename).file_processing_description.should eq(desc)
end

Then /^file "([^"]*)" should have license "([^"]*)"$/ do |filename, license|
  DataFile.find_by_filename!(filename).license.should eq(license)
end

Then /^file "([^"]*)" should have label "([^"]*)"$/ do |filename, label|
  data_file = DataFile.find_by_filename!(filename)
  label_names = data_file.labels.map { |l| l.name}
  label_names.should include(label)
end

Then /^file "([^"]*)" should have grant number "([^"]*)"$/ do |filename, grant_number|
  data_file = DataFile.find_by_filename!(filename)
  grant_number_names = data_file.grant_numbers.map { |gn| gn.name}
  grant_number_names.should include(grant_number)
end

Then /^file "([^"]*)" should have related website "([^"]*)"$/ do |filename, related_website|
  data_file = DataFile.find_by_filename!(filename)
  related_websites = data_file.related_websites.map { |rw| rw.url}
  related_websites.should include(related_website)
end

Then /^file "([^"]*)" should have contributor "([^"]*)"$/ do |filename, contributor|
  data_file = DataFile.find_by_filename!(filename)
  contributors = data_file.contributors.map { |cont| cont.name}
  contributors.should include(contributor)
end

Then /^file "([^"]*)" should have creator "([^"]*)"$/ do |filename, creator|
  data_file = DataFile.find_by_filename!(filename)
  creator = data_file.creator_name
  creator.should eq(creator)
end

Then /^file "([^"]*)" should have tag "([^"]*)"$/ do |filename, tag|
  data_file = DataFile.find_by_filename!(filename)
  tag_names = data_file.tags.map { |t| t.name}
  tag_names.should include(tag)
end

Then /^file "([^"]*)" should have start time "([^"]*)"$/ do |filename, start_time|
  s = DateTime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
  DataFile.find_by_filename!(filename).start_time.should eq(s)
end

Then /^file "([^"]*)" should have end time "([^"]*)"$/ do |filename, end_time|
  s = DateTime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
  DataFile.find_by_filename!(filename).end_time.should eq(s)
end

Then /^file "([^"]*)" should not have start time "([^"]*)"$/ do |filename, start_time|
  s = DateTime.strptime(start_time, '%Y-%m-%d %H:%M:%S')
  DataFile.find_by_filename!(filename).start_time.should_not eq(nil)
  DataFile.find_by_filename!(filename).start_time.should_not eq(s)
end

Then /^file "([^"]*)" should not have end time "([^"]*)"$/ do |filename, end_time|
  s = DateTime.strptime(end_time, '%Y-%m-%d %H:%M:%S')
  DataFile.find_by_filename!(filename).end_time.should_not eq(nil)
  DataFile.find_by_filename!(filename).end_time.should_not eq(s)
end

Then /^file "([^"]*)" should have experiment "([^"]*)"$/ do |filename, experiment|
  DataFile.find_by_filename!(filename).experiment_name.should eq(experiment)
end

Then /^file "([^"]*)" should have title "([^"]*)"$/ do |filename, title|
  DataFile.find_by_filename!(filename).title.should eq(title)
end

Then /^file "([^"]*)" should have transfer status "([^"]*)"$/ do |filename, transfer_status|
  DataFile.find_by_filename!(filename).transfer_status.should eq(transfer_status)
end

Then /^file "([^"]*)" should have access rights type "([^"]*)"$/ do |filename, access_rights_type|
  DataFile.find_by_filename!(filename).access_rights_type.should eq(access_rights_type)
end

Then /^file "([^"]*)" should have parents "([^"]*)"$/ do |filename, parent_filenames|
  file = DataFile.find_by_filename!(filename)
  file.parents.collect(&:filename).sort.should eq(parent_filenames.split(",").sort)
end

Then /^file "([^"]*)" should have children "([^"]*)"$/ do |filename, children_filenames|
  file = DataFile.find_by_filename!(filename)
  file.children.collect(&:filename).sort.should eq(children_filenames.split(",").sort)
end

Then /^file "([^"]*)" should have (\d+) parents/ do |file, count|
  file = DataFile.find_by_filename!(file)
  file.parents.count.should eq(count.to_i)
end

Then /^file "([^"]*)" should have (\d+) children/ do |file, count|
  file = DataFile.find_by_filename!(file)
  file.children.count.should eq(count.to_i)
end

Then /^file "([^"]*)" should have a UUID created$/ do |filename|
  DataFile.find_by_filename!(filename).uuid.should_not be_nil
end

Then /^file "([^"]*)" should not have a UUID created$/ do |filename|
  DataFile.find_by_filename!(filename).uuid.should be_nil
end

Given /^I upload "([^"]*)" with type "([^"]*)" and description "([^"]*)" and experiment "([^"]*)"$/ do |file, type, description, experiment|
  upload(file.strip, type, description, experiment, "", "")
end

Given /^I upload "([^"]*)" with type "([^"]*)" and description "([^"]*)" and experiment "([^"]*)" and tags "([^"]*)"$/ do |file, type, description, experiment, tags|
  upload(file, type, description, experiment, tags, "")
end

Given /^I upload "([^"]*)" with type "([^"]*)" and description "([^"]*)" and experiment "([^"]*)" and parents "([^"]*)"$/ do |file, type, description, experiment, parents|
  upload(file, type, description, experiment, "", parents)
end

Given /^I upload "([^"]*)" with type "([^"]*)" and description "([^"]*)" and experiment "([^"]*)" and access group "([^"]*)"$/ do |file, type, description, experiment|
  upload(file.strip, type, description, experiment, "", "")
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
  sleep(0.5)
  all(".expand_variable").each do |link|
    link.click
  end
  sleep(2)
end

private

def create_data_file(filename, user, type=DataFile::STATUS_RAW, description="desc", experiment=nil, parents=[], children=[], access = DataFile::ACCESS_PRIVATE, access_to_all_institutional_users = true, access_to_user_groups = false, access_groups = [])
  attachment_builder = AttachmentBuilder.new(APP_CONFIG['files_root'], user, FileTypeDeterminer.new, MetadataExtractor.new)

  path = Rails.root.join('samples', filename).to_s
  file = Rack::Test::UploadedFile.new(path, "application/octet-stream")
  experiment = (Experiment.first || Factory(:experiment)) unless experiment
  parent_ids = DataFile.where(:filename => parents.split(", ")).pluck(:id)
  child_ids = DataFile.where(:filename => children.split(", ")).pluck(:id)
  group_ids = AccessGroup.where(:name => access_groups.split(", ")).pluck(:id)

  attachment_builder.build(file, experiment.id, user.id, type, "desc", [], [], [], parent_ids, child_ids, access, access_to_all_institutional_users, access_to_user_groups, group_ids)
end


Then /^there should be (.*) files in the system$/ do |resulting_file_count|
  DataFile.count.should eq(resulting_file_count.to_i)
end

Then /^I should see "([^"]*)" for file "([^"]*)"$/ do |field, file|
  file_obj = DataFile.find_by_filename(file)
  field_id = "file_#{file_obj.id}_#{field.downcase.gsub(/\s/, '_')}"
  expect { find_field(field_id) }.not_to raise_error

end

Then /^I should not see "([^"]*)" for file "([^"]*)"$/ do |field, file|
  file_obj = DataFile.find_by_filename(file)
  field_id = "file_#{file_obj.id}_#{field.downcase.gsub(/\s/, '_')}"
  expect { find_field(field_id) }.to raise_error

end

def upload(file, type, description, experiment, tags, parents)
  visit(path_to("the upload page"))
  select type, :from => "File type"
  select experiment, :from => "Experiment"
  fill_in "Description", :with => description
  attach_file("Select file(s)", File.expand_path(file))
  tags.split(",").each do |tag|
    check(tag) unless tag.blank?
  end
  parents.split(",").each do |parent|
    hidden_field = find :xpath, "//input[@id='data_file_parent_ids']"
    hidden_field.set DataFile.find_by_filename(parent).id
    #fill_in "Parents", :with => DataFile.find_by_filename(parent).id
  end
  click_button "Upload"
  page.should have_content("Your files have been uploaded.")
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
  click_link(link_id)
  wait_until do
    page.evaluate_script('$.active') == 0
  end
end

When /^I remove ([^"]*) from the cart$/ do |name|
  data_file = DataFile.find_by_filename(name)
  click_link("remove_from_cart_#{data_file.id}")
end


# rack-test compatible version of 'add to cart' that doesn't require javascript (selenium)
When /^I add "([^"]*)" to the cart$/ do |name|
  data_file = DataFile.find_by_filename(name)
  User.where('current_sign_in_at is not null').first.cart_items << data_file
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

Then /^the cart for "([^"]*)" should be empty$/ do |email|
  User.find_by_email!(email).cart_items.size.should eq(0)
end

Then /^the cart for "([^"]*)" should contain (\d+) files?$/ do |email, count|
  User.find_by_email!(email).cart_items.size.should eq(count.to_i)
end


When /^the cart for "([^"]*)" contains "([^"]*)"$/ do |email, file_name|
  user = User.find_by_email!(email)
  file = DataFile.find_by_filename(file_name)
  user.cart_items << file
end

When /^the cart for "([^"]*)" should contain only file "([^"]*)"$/ do |email, file_name|
  user = User.find_by_email!(email)
  file = DataFile.find_by_filename(file_name)
  user.cart_items.size.should eq(1)
  user.cart_items.first.id.should eq(file.id)
end

When /^there should be files named "([^"]*)" in the system$/ do |csv_files|
  names = csv_files.split(",").map(&:strip)
  DataFile.count.should eq(names.size), "Expected #{names.size} files but found #{DataFile.count}"
  DataFile.all.collect(&:filename).sort.should eq(names.sort)
  names.each do |name|
    File.exists?("#{APP_CONFIG['files_root']}/#{name}").should eq(true)
  end
end

When /^there should be files named "([^"]*)" that were deleted$/ do |csv_files|
  names = csv_files.split(",").map(&:strip)
  names.each do |name|
    File.exists?("#{APP_CONFIG['files_root']}/#{name}").should eq(false)
  end
end

Then /^file "([^"]*)" should have access level "([^"]*)"$/ do |file, access|
  file = DataFile.find_by_filename!(file)
  file.access.should eq(access)
end

Then /^file "([^"]*)" should be set as private access to all institutional users$/ do |file|
  file = DataFile.find_by_filename!(file)
  file.access_to_all_institutional_users.should be_true
end

Then /^file "([^"]*)" should not be set as private access to all institutional users$/ do |file|
  file = DataFile.find_by_filename!(file)
  file.access_to_all_institutional_users.should be_false
end

Then /^file "([^"]*)" should be set as private access to user groups$/ do |file|
  file = DataFile.find_by_filename!(file)
  file.access_to_user_groups.should be_true
end

Then /^file "([^"]*)" should not be set as private access to user groups$/ do |file|
  file = DataFile.find_by_filename!(file)
  file.access_to_user_groups.should be_false
end

Then /^file "([^"]*)" should have access groups "([^"]*)"$/ do |file, groups|
  file = DataFile.find_by_filename!(file)
  file.access_groups.pluck(:name).sort.should eq(groups.split(",").sort)
end

Then /^file "([^"]*)" should have the private access options: "([^"]*)" to all institutional users, "([^"]*)" to user groups$/ do |file, inst, groups|
  file = DataFile.find_by_filename!(file)
  if inst == "true"
    inst_flag = true
  elsif inst == "false"
    inst_flag = false
  end
  if groups == "true"
    groups_flag = true
  elsif groups == "false"
    groups_flag = false
  end
  file.access_to_all_institutional_users.should eq inst_flag
  file.access_to_user_groups.should eq groups_flag
end

When /^I select "([^"]*)" from the creator select box$/ do |option|
  field = "Creator"
  select(option, :from => field)
end

Then /^"([^"]*)" should be selected for "([^"]*)"$/ do |selected_text, dropdown|
  expect(page).to have_select(dropdown, :selected => selected_text)
end