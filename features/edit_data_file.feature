Feature: Edit data files metadata
  In order to edit what I need
  As a user
  I want to edit the details of data files

  Background:
    Given I have a user "admin@intersect.org.au" with role "Administrator"
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And I have data files
      | filename     | created_at       | uploaded_by                 | start_time        | end_time            | interval | experiment         | file_processing_description | file_processing_status | format | label_list  |
      | datafile.dat | 30/11/2011 10:15 | admin@intersect.org.au      |                   |                     |          | My Nice Experiment | Description of my file      | RAW                    |        |             |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au       | 1/6/2010 15:23:00 | 30/11/2011 12:00:00 | 300      | Other              |                             | UNKNOWN                | TOA5   |             |
      | file.txt     | 02/11/2011 14:00 | researcher@intersect.org.au | 1/5/2010 14:00:00 | 2/6/2011 13:00:00   |          | Silly Experiment   | desc.                       | UNKNOWN                |        |             |
      | error.txt    | 03/13/2011 14:00 | researcher@intersect.org.au | 1/5/2010 14:00:00 | 2/6/2011 13:00:00   |          | Expt1              | desc.                       | ERROR                  |        |             |
      | file_with_labels.txt | 04/11/2013 15:45 | cindy@intersect.org.au  |               |                     |          | Delete Label Example | Test deleting a label from a file | UNKNOWN        |        | this3,that2,test1 |


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
    And I should see select2 field "data_file_label_list" with value ""
    And I fill in "data_file_label_list" with "bebb@|Abba|cu,ba|AA<script></script>"
    And I press "Update"
    Then I should see field "Labels" with value "AA<script></script>, Abba, bebb@, cu,ba"


  #EYETRACKER-88
  @javascript
  Scenario: Delete an existing label from data file
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list data files page
    And I edit data file "file_with_labels.txt"
    And I should see select2 field "data_file_label_list" with value "test1|that2|this3"
    And I remove "that2" from "data_file_label_list" select2 field
    And I check select2 field "data_file_label_list" updated value to "test1,this3"
    And I press "Update"
    Then I should see field "Labels" with value "test1, this3"
