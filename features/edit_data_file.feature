Feature: Edit data files metadata
  In order to edit what I need
  As a user
  I want to edit the details of data files

  Background:
    Given I have a user "admin@intersect.org.au" with role "Administrator"
    Given I have a user "researcher@intersect.org.au" with role "Institutional User"
    And I have data files
      | filename             | created_at       | uploaded_by                 | start_time        | end_time            | interval | experiment           | file_processing_description       | file_processing_status | format | label_list        | contributors     |
      | datafile.dat         | 30/11/2011 10:15 | admin@intersect.org.au      |                   |                     |          | My Nice Experiment   | Description of my file            | RAW                    |        |                   |                  |
      | sample.txt           | 01/12/2011 13:45 | sean@intersect.org.au       | 1/6/2010 15:23:00 | 30/11/2011 12:00:00 | 300      | Other                |                                   | UNKNOWN                | TOA5   |                   |                  |
      | file.txt             | 02/11/2011 14:00 | researcher@intersect.org.au | 1/5/2010 14:00:00 | 2/6/2011 13:00:00   |          | Silly Experiment     | desc.                             | UNKNOWN                |        |                   |                  |
      | error.txt            | 03/13/2011 14:00 | researcher@intersect.org.au | 1/5/2010 14:00:00 | 2/6/2011 13:00:00   |          | Expt1                | desc.                             | ERROR                  |        |                   |                  |
      | file_with_labels.txt | 04/11/2013 15:45 | cindy@intersect.org.au      |                   |                     |          | Delete Label Example | Test deleting a label from a file | UNKNOWN                |        | this3,that2,test1 |                  |
      | file_with_contributors.txt | 04/11/2013 15:45 | tao@intersect.org.au  |                   |                     |          | Delete Contributor Example | Test deleting a contributor from a file | UNKNOWN    |        |                   | this3,that2,test1 |
    And I have data files
      | filename             | created_at       | uploaded_by                 | start_time        | end_time            | interval | experiment           | file_processing_description       | file_processing_status | format | label_list        | related_websites |
      | package1.zip         | 30/12/2011 12:34 | admin@intersect.org.au      | 1/5/2010 14:00:00 | 2/6/2011 13:00:00   |          |samples/package1.zip  |  a package                        | PACKAGE                |        |                   |                  |
    And I have access groups
      | id | name    | primary_user                |  created_at       | status |
      | 1  | group-1 | admin@intersect.org.au      | 26/02/2014 14:18  | true   |
      | 2  | group-2 | researcher@intersect.org.au | 03/03/2014 16:32  | false  |
      | 3  | group-3 | admin@intersect.org.au      | 02/01/2014 00:00  | true   |


  Scenario: ID should be unique
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list data files page
    And I edit data file "sample.txt"
    And I fill in "ID" with "Package 1"
    And I press "Update"
    When I am on the list data files page
    And I edit data file "file.txt"
    And I fill in "ID" with "Package 1"
    And I press "Update"
    Then I should see "ID 'Package 1' is already being used by sample.txt"

  @javascript
  Scenario: Navigate from list and view edit data file page
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list data files page
    And I edit data file "sample.txt"
    Then I should see "sample.txt"
    And I should see "3"
    And I should see "sean@intersect.org.au"
    And I should see select2 field "data_file_label_list" with value ""
    When I follow "Cancel"
    Then I should be on the list data files page

  Scenario: Editing TOA-5 data file as superuser
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list data files page
    And I edit data file "sample.txt"
    Then I should see "2"
    And I fill in "Description" with "oranges"
    And I edit the File Type to "PROCESSED"
    And I edit the Experiment to "My Nice Experiment"
    And I press "Update"
    Then I should see "oranges"
    And I should see "PROCESSED"
    And I should see "My Nice Experiment"

  Scenario: Editing TOA-5 data file as researcher
    Given I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file.txt"
    Then I should see "3"
    And I fill in "Description" with "apples"
    And I edit the File Type to "PROCESSED"
    And I edit the Experiment to "My Nice Experiment"
    And I press "Update"
    Then I should see "apples"
    And I should see "PROCESSED"
    And I should see "My Nice Experiment"

  Scenario: Editing a data file with ERROR status
    Given I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I follow the view link for data file "error.txt"
    Then I should see "ERROR"
    And I should not see "Edit Metadata"

  Scenario: Editing non-TOA-5 data file as superuser
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file.txt"
    And I fill in "Description" with "watermelons"
    And I fill in "Start Time" with "2012-05-23"
    And I fill in "End Time" with "2012-05-31"
    And I press "Update"
    Then I should see "watermelons"
    And I should see "2012-05-23 4:00:00"
    And I should see "2012-05-31 3:00:00"

  Scenario: Editing non-TOA-5 data file as researcher
    Given I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file.txt"
    And I fill in "Description" with "watermelons"
    And I fill in "Start Time" with "2012-05-23"
    And I fill in "End Time" with "2012-05-31"
    And I press "Update"
    Then I should see "watermelons"
    And I should see "2012-05-23 4:00:00"
    And I should see "2012-05-31 3:00:00"

  Scenario: Cancel edit data file
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list data files page
    And I edit data file "sample.txt"
    And I fill in "Description" with "watermelons"
    Then I follow "Cancel"
    And I should not see "watermelons"
    And I should see "sample.txt"

  Scenario: Editing data file that isn't mine
    Given I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    When I follow the view link for data file "datafile.dat"
    Then I should not see "Edit Metadata"

  Scenario: Editing data file name with trailing spaces
    Given I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file.txt"
    And I fill in "Name" with "sample.txt  "
    And I press "Update"
    Then I should see "Filename has already been taken"

  Scenario: When editing metadata the date format is visible
    Given I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file.txt"
    Then I should see "yyyy-mm-dd"

#EYETRACKER-88

  @javascript
  Scenario: Add a new label to data file
    Given I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file.txt"
    And I wait for 2 seconds
    And I should see select2 field "data_file_label_list" with value ""
    And I fill in "data_file_label_list" with "bebb@|Abba|cu,ba|AA<script></script>"
    And I press "Update"
    Then I should see field "Labels" with value "AA<script></script>, Abba, bebb@, cu,ba"

  @javascript
  Scenario: Add a new contributor to data file
    Given I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file.txt"
    And I wait for 2 seconds
    And I should see select2 field "data_file_contributor_list" with value ""
    And I fill in "data_file_contributor_list" with "bebb@|Abba|cuba|AA<script></script>"
    And I press "Update"
    And file "file.txt" should have contributors "AA<script></script>,Abba,bebb@,cuba"

  @javascript
  Scenario: Make a data file private with access groups
    Given I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file.txt"
    And I wait for 2 seconds
    Then I should see element with id "private_access_options"
    And I should not see element with id "user_groups_list"
    When I choose "Public"
    Then I should not see element with id "private_access_options"
    And I should not see element with id "user_groups_list"
    When I choose "Private"
    And I check "Users in Groups"
    Then I should see select2 field "data_file_access_groups" is empty
    When I click on "Groups"
    Then I should see the choice "group-1" in the select2 menu
    And I should see the choice "group-3" in the select2 menu
    And I should not see the choice "group-2" in the select2 menu
    When I choose "group-3" in the select2 menu
    Then I should see select2 field "data_file_access_groups" with array values "3"
    When I click on "Groups"
    Then I should see the choice "group-1" in the select2 menu
    And I should not see the choice "group-3" in the select2 menu
    When I choose "group-1" in the select2 menu
    Then I should see select2 field "data_file_access_groups" with array values "1, 3"
    When I fill in "Groups" with "gibberish"
    Then I should see no matches found in the select2 field

#EYETRACKER-88

  @javascript
  Scenario: Delete an existing label from data file
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file_with_labels.txt"
    And I should see select2 field "data_file_label_list" with value "test1|that2|this3"
    And I remove "that2" from the select2 field
    And I check select2 field "data_file_label_list" updated value to "test1,this3"
    And I press "Update"
    Then I should see field "Labels" with value "test1, this3"

  @javascript
  Scenario: Delete an existing contributor from data file 
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file_with_contributors.txt"
    And I should see select2 field "data_file_contributor_list" with value "test1|that2|this3"
    And I remove "that2" from the select2 field
    And I check select2 field "data_file_contributor_list" updated value to "test1,this3"
    And I press "Update"
    Then file "file_with_contributors.txt" should have contributors "test1,this3"

#EYETRACKER-155
  Scenario: Package filename should not allow illegal characters
    Given I am logged in as "admin@intersect.org.au"
    And I am on the edit data file page for sample.txt
    And I fill in "Name" with "/ \ ? * : | < > "
    And I press "Update"
    Then I should see "cannot contain any of the following characters: / \ ? * : | < >"

#EYETRACKER-144
  @javascript
  Scenario: Remove unused labels from users view
    Given I have labels "label_1, label_2, label_3, label_4, label_5, terrier"
    And I have data files
      | filename      | created_at       | uploaded_by                 | file_processing_status | experiment    | label_list |
      | datafile1.dat | 04/12/2013 11:53 | researcher@intersect.org.au | RAW                    | My Experiment | label_1    |
      | sample2.txt   | 01/12/2011 13:45 | researcher@intersect.org.au | CLEANSED               | Experiment 2  | label_5    |
    And I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I edit data file "sample2.txt"
    And I fill in "Labels" with "lab"
    Then I should see the choice "label_1" in the select2 menu
    And I choose "label_1" in the select2 menu
    And I fill in "Labels" with "th"
    Then I should see "Please enter 1 more character"
    And I fill in "Labels" with "thi"
    And I should see the choice "this3" in the select2 menu
    When I choose "this3" in the select2 menu
    And I fill in "Labels" with "label_2"
    And I choose "label_2" in the select2 menu
    And I remove "label_5" from the select2 field
    And I wait for 1 seconds
    And I press "Update"
    Then I should see field "Labels" with value "label_1, label_2, this3"
    When I am on the list data files page
    And I edit data file "file.txt"
    And I fill in "Labels" with "l"
    Then I should see "Please enter 2 more characters"
    And I fill in "Labels" with "lab"
    Then I should see the choice "lab" in the select2 menu
    And I should see the choice "label_1" in the select2 menu
    And I should see the choice "label_2" in the select2 menu
    And I should not see the choice "label_3" in the select2 menu
    And I should not see the choice "label_4" in the select2 menu
    And I should not see the choice "label_5" in the select2 menu
    When I fill in "Labels" with "test"
    Then I should see the choice "test" in the select2 menu
    And I should see the choice "test1" in the select2 menu
    And I should not see the choice "that2" in the select2 menu
    And I should not see the choice "this3" in the select2 menu
    And I should not see the choice "terrier" in the select2 menu

  @javascript
  Scenario: Remove unused contributors from users view
    Given I have contributors "cont_1, cont_2, cont_3, cont_4, cont_5, prof"
    And I have data files
      | filename      | created_at       | uploaded_by                 | file_processing_status | experiment    | contributor_list |
      | datafile1.dat | 04/12/2013 11:53 | researcher@intersect.org.au | RAW                    | My Experiment | cont_1    |
      | sample2.txt   | 01/12/2011 13:45 | researcher@intersect.org.au | CLEANSED               | Experiment 2  | cont_5    |
    And I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I edit data file "sample2.txt"
    And I fill in "Contributors" with "cont"
    Then I should see the choice "cont_1" in the select2 menu
    And I choose "cont_1" in the select2 menu
    And I fill in "Contributors" with "th"
    Then I should see "Please enter 1 more character"
    And I fill in "Contributors" with "thi"
    And I should see the choice "this3" in the select2 menu
    When I choose "this3" in the select2 menu
    And I fill in "Contributors" with "cont_2"
    And I choose "cont_2" in the select2 menu
    And I remove "cont_5" from the select2 field
    And I wait for 1 seconds
    And I press "Update"
    Then file "sample2.txt" should have contributors "cont_1,cont_2,this3"
    When I am on the list data files page
    And I edit data file "file.txt"
    And I fill in "Contributors" with "c"
    Then I should see "Please enter 2 more characters"
    And I fill in "Contributors" with "con"
    Then I should see the choice "con" in the select2 menu
    And I should see the choice "cont_1" in the select2 menu
    And I should see the choice "cont_2" in the select2 menu
    And I should not see the choice "cont_3" in the select2 menu
    And I should not see the choice "cont_4" in the select2 menu
    And I should not see the choice "cont_5" in the select2 menu
    When I fill in "Contributors" with "test"
    Then I should see the choice "test" in the select2 menu
    And I should see the choice "test1" in the select2 menu
    And I should not see the choice "that2" in the select2 menu
    And I should not see the choice "this3" in the select2 menu
    And I should not see the choice "terrier" in the select2 menu

  @wip
  Scenario: Editing public/private access in data file as researcher
    Given I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file.txt"
    And I choose "Public"
    And I press "Update"
    Then I should be on the data file details page for file.txt
    And I should see "The data file was saved successfully"
    And I should see field "Access" with value "Public"
    Then I follow "Edit Metadata"
    And I choose "Private"
    And I press "Update"
    Then I should be on the data file details page for file.txt
    And I should see "The data file was saved successfully"
    And I should see field "Access" with value "Private"

  @javascript
  Scenario: Add a new related website to data file
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list data files page
    And I edit data file "package1.zip"
    And I wait for 2 seconds
    And I should see select2 field "data_file_related_website_list" with value ""
    And I fill in "data_file_related_website_list" with "http://www.example.com"
    And I check select2 field "data_file_related_website_list" updated value to "http://www.example.com"
    And I press "Update"
    When I should be on the data file details page for package1.zip
    Then I should see field "Related Websites" with value "http://www.example.com"

  @javascript
  Scenario: Cannot update a data file with invalid related websites
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list data files page
    And I edit data file "package1.zip"
    And I should see select2 field "data_file_related_website_list" with value ""
    And I fill in "data_file_related_website_list" with "webweb|test:123|http://sdjfklsdjfklsdjflksdjfklsdjflsdjfksdjflsdjflksdjklfjsdlkfjskdljflksdjfklsdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflksdjfklsdjflksdjfklsdjfkldsjfklsdjflksdjflksdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflkdsjflksdjfklsdjflksdjfklsdjfklsjfklsdjfklsdjfklsdjfklsdjfklsdjfklsdjflksdsdjfklsdjfklsdjflksdjfklsdjflsdjfksdjflsdjflksdjklfjsdlkfjskdljflksdjfklsdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflksdjfklsdjflksdjfklsdjfkldsjfklsdjflksdjflksdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflkdsjflksdjfklsdjflksdjfklsdjfklsjfklsdjfklsdjfklsdjfklsdjfklsdjfklsdjflksd.com"
    And I check select2 field "data_file_related_website_list" updated value to "webweb|test:123|http://sdjfklsdjfklsdjflksdjfklsdjflsdjfksdjflsdjflksdjklfjsdlkfjskdljflksdjfklsdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflksdjfklsdjflksdjfklsdjfkldsjfklsdjflksdjflksdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflkdsjflksdjfklsdjflksdjfklsdjfklsjfklsdjfklsdjfklsdjfklsdjfklsdjfklsdjflksdsdjfklsdjfklsdjflksdjfklsdjflsdjfksdjflsdjflksdjklfjsdlkfjskdljflksdjfklsdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflksdjfklsdjflksdjfklsdjfkldsjfklsdjflksdjflksdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflkdsjflksdjfklsdjflksdjfklsdjfklsjfklsdjfklsdjfklsdjfklsdjfklsdjfklsdjflksd.com"
    And I press "Update"
    Then I should see "Please correct the following before continuing: Related websites url webweb is not a valid url Related websites url test:123 is not a valid url Related websites url is too long (maximum is 80 characters)"

#UWSHIEVMOD-131
  @javascript
  Scenario: Creator should be the logged in user by default and changeable
    Given I am logged in as "researcher@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file.txt"
    And I wait for 2 seconds
    And "Fred Bloggs (researcher@intersect.org.au)" should be selected for "Creator"
    And I select "Fred Bloggs (admin@intersect.org.au)" from the creator select box
    And I press "Update"
    Then I should see field "Creator" with value "Fred Bloggs (admin@intersect.org.au)"