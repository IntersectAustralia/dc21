Feature: Edit data files metadata
  In order to edit what I need
  As a user
  I want to edit the details of data files

  Background:
      Given I have a user "admin@intersect.org.au" with role "Administrator"
      Given I have a user "researcher@intersect.org.au" with role "Researcher"
      And I have data files
        | filename     | created_at       | uploaded_by                 | start_time        | end_time            | interval | experiment         | file_processing_description | file_processing_status | format   |
        | datafile.dat | 30/11/2011 10:15 | admin@intersect.org.au   |                   |                     |          | My Nice Experiment | Description of my file      | RAW                    |          |
        | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au       | 1/6/2010 15:23:00 | 30/11/2011 12:00:00 | 300      | Other              |                             | UNKNOWN                | TOA5     |
        | file.txt     | 02/11/2011 14:00 | researcher@intersect.org.au | 1/5/2010 14:00:00 | 2/6/2011 13:00:00   |          | Silly Experiment   | desc.                       | UNKNOWN                |          |
        | error.txt    | 03/13/2011 14:00 | researcher@intersect.org.au | 1/5/2010 14:00:00 | 2/6/2011 13:00:00   |          | Expt1              | desc.                       | ERROR                  |          |

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

  Scenario: Navigate from list and view edit data file page
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list data files page
    And I edit data file "sample.txt"
    Then I should see "sample.txt"
    And I should see "3"
    And I should see "sean@intersect.org.au"
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