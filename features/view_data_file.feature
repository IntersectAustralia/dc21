Feature: View the details of a data file
  In order to find out more
  As a user
  I want to view the details of a data file

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have data files
      | filename     | created_at       | uploaded_by               | start_time           | end_time                | interval | experiment         | file_processing_description | file_processing_status |
      | datafile.dat | 30/11/2011 10:15 | georgina@intersect.org.au |                      |                         |          | My Nice Experiment | Description of my file      | RAW                    |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | 1/6/2010 6:42:01 UTC | 30/11/2011 18:05:23 UTC | 300      |                    |                             |                        |

  Scenario: Navigate from list and view a data file with start and end times
    When I am on the list data files page
    And I follow the view link for data file "sample.txt"
    Then I should see details displayed
      | Name            | sample.txt            |
      | Date added      | 2011-12-01 13:45      |
      | Added by        | sean@intersect.org.au |
      | Start time      | 2010-06-01  6:42:01   |
      | End time        | 2011-11-30 18:05:23   |
      | Sample interval | 5 minutes             |
    When I follow "Back"
    Then I should be on the list data files page

  Scenario: View a data file with no start/end times
    When I am on the data file details page for datafile.dat
    Then I should not see "Start time" within the file details area
    Then I should not see "End time" within the file details area

  Scenario: View a file with status/description experiment info
    When I am on the data file details page for datafile.dat
    Then I should see details displayed
      | Experiment        | My Nice Experiment     |
      | Processing status | RAW                    |
      | Description       | Description of my file |

  Scenario: View a file with NO status/description experiment info
    When I am on the data file details page for sample.txt
    Then I should see details displayed
      | Experiment        |           |
      | Processing status | UNDEFINED |
      | Description       |           |

  Scenario: Navigate back to the list
    When I am on the data file details page for sample.txt
    And I follow "Back"
    Then I should be on the list data files page

  Scenario: Must be logged in to view the details
    Then users should be required to login on the data file details page for sample.txt

  Scenario: TOA5 file shows mapped station name where it has been mapped to a facility
    Given I have facility "WTC Station" with code "WTC01"
    And I have uploaded "WTC01_Table1.dat"
    And I am on the list data files page
    When I follow the view link for data file "WTC01_Table1.dat"
    Then I should see field "Facility" with value "WTC01 (WTC Station)"

  Scenario: TOA5 file shows station code only if no mapping to facility exists
    Given I have uploaded "WTC01_Table1.dat"
    When I am on the list data files page
    And I follow the view link for data file "WTC01_Table1.dat"
    Then I should see field "Facility" with value "WTC01"

  Scenario: TOA5 file shows correctly mapped column names in file info table
    Given I have uploaded "Test_Column_Table.dat"
    And I have column mappings
      | name                         | code                 |
      | Average Soil Temperature (1) | SoilTempProbe_Avg(1) |
      | Average Soil Temperature (3) | soilTempprobe_Avg(3) |
      | Average Soil Temperature (4) | Soiltempprobe_Avg(4) |
    When I am on the list data files page
    And I follow the view link for data file "Test_Column_Table.dat"
    Then I should see "column_info" table with
      | Column               | Column Mapping               | Unit  | Measurement Type |
      | SoilTempProbe_Avg(1) | Average Soil Temperature (1) | Deg C | Avg              |
      | SoilTempProbe_Avg(2) |                              | Deg C | Avg              |
      | SoilTempProbe_Avg(3) | Average Soil Temperature (3) | Deg C | Avg              |
      | SoilTempProbe_Avg(4) | Average Soil Temperature (4) | Deg C | Avg              |
      | SoilTempProbe_Avg(5) |                              | Deg C | Avg              |
      | SoilTempProbe_Avg(6) |                              | Deg C | Avg              |

  Scenario: Filling in missing column mappings - only missing mappings should be shown
    Given I have uploaded "Test_Column_Table.dat"
    And I have column mappings
      | name                         | code                 |
      | Average Soil Temperature (1) | SoilTempProbe_Avg(1) |
      | Average Soil Temperature (3) | soilTempprobe_Avg(3) |
      | Average Soil Temperature (4) | Soiltempprobe_Avg(4) |
    When I am on the list data files page
    And I follow the view link for data file "Test_Column_Table.dat"
    And I follow "Fill in column mappings"
    Then I should see "SoilTempProbe_Avg(2)"
    And I should see "SoilTempProbe_Avg(5)"
    And I should not see "SoilTempProbe_Avg(3)"
    And I should not see "SoilTempProbe_Avg(4)"

  Scenario: Fill in missing column mappings with valid information
    Given I have uploaded "Test_Column_Table.dat"
    And I have column mappings
      | name                         | code                 |
      | Average Soil Temperature (1) | SoilTempProbe_Avg(1) |
      | Average Soil Temperature (3) | soilTempprobe_Avg(3) |
      | Average Soil Temperature (4) | Soiltempprobe_Avg(4) |
    When I am on the list data files page
    And I follow the view link for data file "Test_Column_Table.dat"
    And I follow "Fill in column mappings"
    And I select "Rainfall" from "column_mappings_0_name"
    And I select "Wind Speed" from "column_mappings_1_name"
    And I select "Sample" from "column_mappings_2_name"
    And I press "Submit Column Mappings"
    Then I should see "column_info" table with
      | Column               | Column Mapping               | Unit  | Measurement Type |
      | SoilTempProbe_Avg(1) | Average Soil Temperature (1) | Deg C | Avg              |
      | SoilTempProbe_Avg(2) | Rainfall                     | Deg C | Avg              |
      | SoilTempProbe_Avg(3) | Average Soil Temperature (3) | Deg C | Avg              |
      | SoilTempProbe_Avg(4) | Average Soil Temperature (4) | Deg C | Avg              |
      | SoilTempProbe_Avg(5) | Wind Speed                   | Deg C | Avg              |
      | SoilTempProbe_Avg(6) | Sample                       | Deg C | Avg              |

  Scenario: Fill in missing column mappings button should not be visible if none are missing
    Given I have uploaded "Test_Column_Table.dat"
    And I have column mappings
      | name                         | code                 |
      | Average Soil Temperature (1) | SoilTempProbe_Avg(1) |
      | Average Soil Temperature (3) | soilTempprobe_Avg(2) |
      | Average Soil Temperature (4) | Soiltempprobe_Avg(3) |
      | Average Soil Temperature (1) | SoilTempProbe_Avg(4) |
      | Average Soil Temperature (3) | soilTempprobe_Avg(5) |
      | Average Soil Temperature (4) | Soiltempprobe_Avg(6) |
    When I am on the list data files page
    And I follow the view link for data file "Test_Column_Table.dat"
    Then I should not see "Fill in column mappings"

# This scenario no longer possible, but it may become relevant soon.
# TODO Delete in sprint 4
#  Scenario: Fill in missing column mappings with invalid information
#    Given I have uploaded "Test_Column_Table.dat"
#    When I am on the list data files page
#    And I follow the view link for data file "Test_Column_Table.dat"
#    And I follow "Fill in column mappings"
#    And I press "Submit Column Mappings"
#    Then I should see "Name can't be blank"




