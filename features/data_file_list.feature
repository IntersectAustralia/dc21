Feature: View the list of data files
  In order to find what I need
  As a user
  I want to view a list of data files

  Background:
    Given I am logged in as "georgina@intersect.org.au"

  Scenario: View the list
    Given I have data files
      | filename     | created_at       | uploaded_by               | file_processing_status | experiment    |
      | datafile.dat | 30/11/2011 10:15 | georgina@intersect.org.au | RAW                    | My Experiment |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | CLEANSED               | Experiment 2  |
    When I am on the list data files page
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by                  | Type     | Experiment    |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | CLEANSED | Experiment 2  |
      | datafile.dat | 2011-11-30 10:15 | georgina@intersect.org.au | RAW      | My Experiment |
    And I should see "Showing all 2 files"

  Scenario: View the list when there's nothing to show
    When I am on the list data files page
    Then I should see "No matching files"

  Scenario: Must be logged in to view the list
    Then users should be required to login on the list data files page

  @javascript
  Scenario: Sort the list of files by filename
    Given I have data files
      | filename     | created_at       | uploaded_by               | file_processing_status | experiment    |
      | datafile.dat | 30/11/2011 10:15 | georgina@intersect.org.au | RAW                    | My Experiment |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | UNKNOWN                | Other         |
    When I am on the list data files page
    When I follow "Filename"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by                  | Type    | Experiment    |
      | datafile.dat | 2011-11-30 10:15 | georgina@intersect.org.au | RAW     | My Experiment |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | UNKNOWN | Other         |
    When I follow "Filename"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by                  | Type    | Experiment    |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | UNKNOWN | Other         |
      | datafile.dat | 2011-11-30 10:15 | georgina@intersect.org.au | RAW     | My Experiment |

  @javascript
  Scenario: Sort the list of files by created at
    Given I have data files
      | filename     | created_at       | uploaded_by               | file_processing_status | experiment    |
      | datafile.dat | 30/11/2011 10:15 | georgina@intersect.org.au | RAW                    | My Experiment |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | CLEANSED               | Experiment 2  |
    When I am on the list data files page
    And I follow "Date added"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by                  | Type     | Experiment    |
      | datafile.dat | 2011-11-30 10:15 | georgina@intersect.org.au | RAW      | My Experiment |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | CLEANSED | Experiment 2  |
    And I follow "Date added"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by                  | Type     | Experiment    |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | CLEANSED | Experiment 2  |
      | datafile.dat | 2011-11-30 10:15 | georgina@intersect.org.au | RAW      | My Experiment |

  @javascript
  Scenario: Sort the list of files by uploader
    Given I have data files
      | filename     | created_at       | uploaded_by               | file_processing_status | experiment    |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | CLEANSED               | Experiment 2  |
      | datafile.dat | 30/11/2011 10:15 | georgina@intersect.org.au | RAW                    | My Experiment |
    When I am on the list data files page
    And I follow "Added by"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by                  | Type     | Experiment    |
      | datafile.dat | 2011-11-30 10:15 | georgina@intersect.org.au | RAW      | My Experiment |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | CLEANSED | Experiment 2  |
    And I follow "Added by"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by                  | Type     | Experiment    |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | CLEANSED | Experiment 2  |
      | datafile.dat | 2011-11-30 10:15 | georgina@intersect.org.au | RAW      | My Experiment |

  @javascript
  Scenario: Sort the list of files by status
    Given I have data files
      | filename     | created_at       | uploaded_by               | file_processing_status | experiment    |
      | datafile.dat | 30/11/2011 10:15 | georgina@intersect.org.au | RAW                    | My Experiment |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | CLEANSED               | Experiment 2  |
    When I am on the list data files page
    And I follow "Type"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by                  | Type     | Experiment    |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | CLEANSED | Experiment 2  |
      | datafile.dat | 2011-11-30 10:15 | georgina@intersect.org.au | RAW      | My Experiment |
    And I follow "Type"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by                  | Type     | Experiment    |
      | datafile.dat | 2011-11-30 10:15 | georgina@intersect.org.au | RAW      | My Experiment |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | CLEANSED | Experiment 2  |

  @javascript
  Scenario: Sort the list of files by experiment
    Given I have data files
      | filename     | created_at       | uploaded_by               | file_processing_status | experiment    |
      | datafile.dat | 30/11/2011 10:15 | georgina@intersect.org.au | RAW                    | My Experiment |
      | sample2.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | CLEANSED               | Experiment 2  |
      | sample1.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | CLEANSED               | Other         |
    When I am on the list data files page
    And I follow "Experiment"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by                  | Type     | Experiment    |
      | sample2.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | CLEANSED | Experiment 2  |
      | datafile.dat | 2011-11-30 10:15 | georgina@intersect.org.au | RAW      | My Experiment |
      | sample1.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | CLEANSED | Other         |
    And I follow "Experiment"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by                  | Type     | Experiment    |
      | sample1.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | CLEANSED | Other         |
      | datafile.dat | 2011-11-30 10:15 | georgina@intersect.org.au | RAW      | My Experiment |
      | sample2.txt   | 2011-12-01 13:45 | sean@intersect.org.au     | CLEANSED | Experiment 2  |

  @javascript
  Scenario: User clicks download without selecting files
    Given I have data files
      | filename    | created_at       | uploaded_by               | path                |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | samples/sample1.txt |
      | sample2.txt | 30/11/2011 10:15 | georgina@intersect.org.au | samples/sample2.txt |
    When I am on the list data files page
    #And I click on "Download Files"
    Then I should not see button "Download Selected Files"

  @javascript
  Scenario: Download button appears when files are selected
    Given I have data files
      | filename    | created_at       | uploaded_by               | start_time       | end_time            | path                |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample1.txt |
      | sample2.txt | 30/11/2011 10:15 | georgina@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample2.txt |
    When I am on the list data files page
    #And I click on "Download Files"
    And I should not see button "Download Selected Files"
    And I check "ids[]"
    Then I should see button "Download Selected Files"

  @javascript
  Scenario: Download Selected Files buttons vanish/appear with other download-related controls (when files are selected)
    Given I have data files
      | filename    | created_at       | uploaded_by               | start_time       | end_time            | path                |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample1.txt |
      | sample2.txt | 30/11/2011 10:15 | georgina@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample2.txt |
    When I am on the list data files page
    #And I click on "Download Files"
    And I check "ids[]"
    Then I should see button "Download Selected Files"
    #And I click on "Download Files"
    #And I should not see button "Download Selected Files"


  Scenario: User downloads a selection of files
    Given I have data files
      | filename    | created_at       | uploaded_by               | start_time       | end_time            | path                |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample1.txt |
      | sample2.txt | 30/11/2011 10:15 | georgina@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample2.txt |
    When I am on the list data files page
    #And I click on "Download Files"
    And I check "ids[]"
    And I press "Download Selected Files"
    Then I should get a download of all data files

  @wip @javascript

  Scenario: Select-all link marks all files
    Given I have data files
      | filename    | created_at       | uploaded_by               | path                |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | samples/sample1.txt |
      | sample2.txt | 30/11/2011 10:15 | georgina@intersect.org.au | samples/sample2.txt |
    When I am on the list data files page
    #And I click on "Download Files"
    And I click on "All"
#    Then All checkboxes in "datafiles" are checked

  @javascript
  Scenario: Clicking download files makes checkboxes and buttons appear
    Given I have data files
      | filename    | created_at       | uploaded_by               | path                |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | samples/sample1.txt |
      | sample2.txt | 30/11/2011 10:15 | georgina@intersect.org.au | samples/sample2.txt |
    When I am on the list data files page
    #And I click on "Download Files"
    Then I check "ids[]"
    And I press "Download Selected Files"
   
