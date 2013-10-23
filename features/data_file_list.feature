Feature: View the list of data files
  In order to find what I need
  As a user
  I want to view a list of data files

  Background:
    Given I am logged in as "admin@intersect.org.au"

  Scenario: View the list
    Given I have data files
      | filename     | created_at       | uploaded_by            | file_processing_status | experiment    |
      | datafile.dat | 30/11/2011 10:15 | admin@intersect.org.au | RAW                    | My Experiment |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au  | CLEANSED               | Experiment 2  |
    When I am on the list data files page
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by               | Type     | Experiment    |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au  | CLEANSED | Experiment 2  |
      | datafile.dat | 2011-11-30 10:15 | admin@intersect.org.au | RAW      | My Experiment |
    And I should see "Showing all 2 files"

  Scenario: View the list when there's nothing to show
    When I am on the list data files page
    Then I should see "No matching files"

  Scenario: Must be logged in to view the list
    Then users should be required to login on the list data files page

  @javascript
  Scenario: Sort the list of files by filename
    Given I have data files
      | filename     | created_at       | uploaded_by            | file_processing_status | experiment    |
      | datafile.dat | 30/11/2011 10:15 | admin@intersect.org.au | RAW                    | My Experiment |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au  | UNKNOWN                | Other         |
    When I am on the list data files page
    When I follow "Filename"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by               | Type    | Experiment    |
      | datafile.dat | 2011-11-30 10:15 | admin@intersect.org.au | RAW     | My Experiment |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au  | UNKNOWN | Other         |
    When I follow "Filename"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by               | Type    | Experiment    |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au  | UNKNOWN | Other         |
      | datafile.dat | 2011-11-30 10:15 | admin@intersect.org.au | RAW     | My Experiment |

  @javascript
  Scenario: Sort the list of files by created at
    Given I have data files
      | filename     | created_at       | uploaded_by            | file_processing_status | experiment    |
      | datafile.dat | 30/11/2011 10:15 | admin@intersect.org.au | RAW                    | My Experiment |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au  | CLEANSED               | Experiment 2  |
    When I am on the list data files page
    And I follow "Date added"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by               | Type     | Experiment    |
      | datafile.dat | 2011-11-30 10:15 | admin@intersect.org.au | RAW      | My Experiment |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au  | CLEANSED | Experiment 2  |
    And I follow "Date added"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by               | Type     | Experiment    |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au  | CLEANSED | Experiment 2  |
      | datafile.dat | 2011-11-30 10:15 | admin@intersect.org.au | RAW      | My Experiment |

  @javascript
  Scenario: Sort the list of files by uploader
    Given I have data files
      | filename     | created_at       | uploaded_by            | file_processing_status | experiment    |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au  | CLEANSED               | Experiment 2  |
      | datafile.dat | 30/11/2011 10:15 | admin@intersect.org.au | RAW                    | My Experiment |
    When I am on the list data files page
    And I follow "Added by"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by               | Type     | Experiment    |
      | datafile.dat | 2011-11-30 10:15 | admin@intersect.org.au | RAW      | My Experiment |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au  | CLEANSED | Experiment 2  |
    And I follow "Added by"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by               | Type     | Experiment    |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au  | CLEANSED | Experiment 2  |
      | datafile.dat | 2011-11-30 10:15 | admin@intersect.org.au | RAW      | My Experiment |

  @javascript
  Scenario: Sort the list of files by status
    Given I have data files
      | filename     | created_at       | uploaded_by            | file_processing_status | experiment    |
      | datafile.dat | 30/11/2011 10:15 | admin@intersect.org.au | RAW                    | My Experiment |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au  | CLEANSED               | Experiment 2  |
    When I am on the list data files page
    And I follow "Type"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by               | Type     | Experiment    |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au  | CLEANSED | Experiment 2  |
      | datafile.dat | 2011-11-30 10:15 | admin@intersect.org.au | RAW      | My Experiment |
    And I follow "Type"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by               | Type     | Experiment    |
      | datafile.dat | 2011-11-30 10:15 | admin@intersect.org.au | RAW      | My Experiment |
      | sample.txt   | 2011-12-01 13:45 | sean@intersect.org.au  | CLEANSED | Experiment 2  |

  @javascript
  Scenario: Sort the list of files by experiment
    Given I have data files
      | filename     | created_at       | uploaded_by            | file_processing_status | experiment    |
      | datafile.dat | 30/11/2011 10:15 | admin@intersect.org.au | RAW                    | My Experiment |
      | sample2.txt  | 01/12/2011 13:45 | sean@intersect.org.au  | CLEANSED               | Experiment 2  |
      | sample1.txt  | 01/12/2011 13:45 | sean@intersect.org.au  | CLEANSED               | Other         |
    When I am on the list data files page
    And I follow "Experiment"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by               | Type     | Experiment    |
      | sample2.txt  | 2011-12-01 13:45 | sean@intersect.org.au  | CLEANSED | Experiment 2  |
      | datafile.dat | 2011-11-30 10:15 | admin@intersect.org.au | RAW      | My Experiment |
      | sample1.txt  | 2011-12-01 13:45 | sean@intersect.org.au  | CLEANSED | Other         |
    And I follow "Experiment"
    Then I should see "exploredata" table with
      | Filename     | Date added       | Added by               | Type     | Experiment    |
      | sample1.txt  | 2011-12-01 13:45 | sean@intersect.org.au  | CLEANSED | Other         |
      | datafile.dat | 2011-11-30 10:15 | admin@intersect.org.au | RAW      | My Experiment |
      | sample2.txt  | 2011-12-01 13:45 | sean@intersect.org.au  | CLEANSED | Experiment 2  |

  Scenario: Exploring data by Date has a date format prompt
    Given I am on the list data files page
    And I click on "Date:"
    Then I should see "yyyy-mm-dd"

  Scenario: Exploring data by Upload Date has a date format prompt
    Given I am on the list data files page
    And I click on "Date Added:"
    Then I should see "yyyy-mm-dd"


