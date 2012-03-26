Feature: Overlapping Files
  In order to remove duplicate data
  As a technician
  I want to overwrite overlapped files
  And I don't want to overlap mismatching files

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And I am logged in as "researcher@intersect.org.au"
    And I have experiment "My Experiment"

  Scenario: Safe overlap one file supplying description and experiment
    Given I have data files
      | filename              | uploaded_by                 | path                                                  | file_processing_status | experiment | file_processing_description | start_time          | end_time            | format |
      | WTC01_Table1_orig.dat | researcher@intersect.org.au | samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat | RAW                    | Other      | orig wtc01_table1.dat       | 2011-08-11 19:30:00 | 2011-08-31 23:45:00 | TOA5   |
    And file "WTC01_Table1_orig.dat" has the following metadata
      | key          | value  |
      | station_name | WTC01  |
      | table_name   | Table1 |
    And I upload "samples/WTC01_Table1.dat" with type "RAW" and description "new description" and experiment "My Experiment"
    When I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename         | Added by                    | Start time          | End time            | Type |
      | WTC01_Table1.dat | researcher@intersect.org.au | 2011-08-11  9:30:00 | 2011-11-02 13:00:00 | RAW               |
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Type | RAW             |
      | Description       | new description |
      | Experiment        | My Experiment   |

  Scenario: Safe overlap one file inherits description
    Given I have data files
      | filename              | uploaded_by                 | path                                                  | file_processing_status | experiment | file_processing_description | start_time          | end_time            | format |
      | WTC01_Table1_orig.dat | researcher@intersect.org.au | samples/subsetted/range_aug_1_aug_31/WTC01_Table1.dat | RAW                    | Other      | orig wtc01_table1.dat       | 2011-08-11 19:30:00 | 2011-08-31 23:45:00 | TOA5   |
    And file "WTC01_Table1_orig.dat" has the following metadata
      | key          | value  |
      | station_name | WTC01  |
      | table_name   | Table1 |
    And I upload "samples/WTC01_Table1.dat" with type "RAW" and description "" and experiment "My Experiment"
    When I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename         | Added by                    | Start time          | End time            | Type |
      | WTC01_Table1.dat | researcher@intersect.org.au | 2011-08-11  9:30:00 | 2011-11-02 13:00:00 | RAW               |
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Type | RAW                   |
      | Description       | orig wtc01_table1.dat |
