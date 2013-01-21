Feature: Overlapping Files
  In order to remove duplicate data
  As a technician
  I want to overwrite overlapped files
  And I don't want to overlap mismatching files

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    Given I have a user "other@intersect.org.au" with role "Researcher"
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
      | Filename         | Added by                    | Type |
      | WTC01_Table1.dat | researcher@intersect.org.au | RAW  |
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Type        | RAW             |
      | Description | new description |
      | Experiment  | My Experiment   |

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
      | Filename         | Added by                    | Type |
      | WTC01_Table1.dat | researcher@intersect.org.au | RAW  |
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Type        | RAW                   |
      | Description | orig wtc01_table1.dat |

  Scenario: Safe overlap removes replaced files from carts and adds new one to carts
    Given I have uploaded "subsetted/range_oct_10_oct_12/weather_station_05_min_10_to_12.dat" with type "RAW"
    And I have uploaded "subsetted/range_oct_13_oct_15/weather_station_05_min_13_to_15.dat" with type "RAW"
    And the cart for "researcher@intersect.org.au" contains "weather_station_05_min_10_to_12.dat"
    And the cart for "researcher@intersect.org.au" contains "weather_station_05_min_13_to_15.dat"
    And the cart for "other@intersect.org.au" contains "weather_station_05_min_10_to_12.dat"
    Then the cart for "other@intersect.org.au" should contain 1 file
    And the cart for "researcher@intersect.org.au" should contain 2 files
    When I upload "samples/weather_station_05_min.dat" with type "RAW" and description "new description" and experiment "My Experiment"
    Then I should see "Carts have been updated."
    And I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename                   | Added by                    | Type |
      | weather_station_05_min.dat | researcher@intersect.org.au | RAW  |
    And the cart for "other@intersect.org.au" should contain only file "weather_station_05_min.dat"
    And the cart for "researcher@intersect.org.au" should contain only file "weather_station_05_min.dat"

  Scenario: Safe overlap doesn't show carts message if no files in carts
    Given I have uploaded "subsetted/range_oct_10_oct_12/weather_station_05_min_10_to_12.dat" with type "RAW"
    And I have uploaded "subsetted/range_oct_13_oct_15/weather_station_05_min_13_to_15.dat" with type "RAW"
    When I upload "samples/weather_station_05_min.dat" with type "RAW" and description "new description" and experiment "My Experiment"
    Then I should not see "Carts have been updated."
    And I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename                   | Added by                    | Type |
      | weather_station_05_min.dat | researcher@intersect.org.au | RAW  |
    And the cart for "other@intersect.org.au" should be empty
    And the cart for "researcher@intersect.org.au" should be empty

