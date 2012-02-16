Feature: Overlapping Files
  In order to remove duplicate data
  As a technician
  I want to overwrite overlapped files
  And I don't want to overlap mismatching files

  Background:
    Given I am logged in as "georgina@intersect.org.au"

  Scenario: Safe overlap one file supplying description
    Given I have data files
      | filename              | uploaded_by               | path                                                  | file_processing_status | file_processing_description | start_time          | end_time            | format |
      | WTC01_Table1_orig.dat | georgina@intersect.org.au | samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat | RAW                    | orig wtc01_table1.dat       | 2011-08-11 19:30:00 | 2011-08-31 23:45:00 | TOA5   |
    And file "WTC01_Table1_orig.dat" has the following metadata
      | key          | value  |
      | station_name | WTC01  |
      | table_name   | Table1 |

    And I am on the upload page
    And I upload "WTC01_Table1.dat" through the applet
    And I follow "Next"

    When I select "RAW" from the select box for "WTC01_Table1.dat"
    And I press "Done"

    Then I should be on the list data files page
    And I should see only these rows in "exploredata" table
      | Filename         | Added by                  | Start time            | End time            | Processing Status |
      | WTC01_Table1.dat | georgina@intersect.org.au | 2011-08-11  9:30:00   | 2011-11-02 13:00:00 | RAW               |

  @wip
  Scenario: Safe overlap one file inherits description
