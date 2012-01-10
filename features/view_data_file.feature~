Feature: View the details of a data file
  In order to find out more
  As a user
  I want to view the details of a data file

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have data files
      | filename     | created_at       | uploaded_by               | start_time           | end_time                | interval |
      | datafile.dat | 30/11/2011 10:15 | georgina@intersect.org.au |                      |                         |          |
      | sample.txt   | 01/12/2011 13:45 | sean@intersect.org.au     | 1/6/2010 6:42:01 UTC | 30/11/2011 18:05:23 UTC |  300     |

  Scenario: Navigate from list and view a data file
    When I am on the list data files page
    And I follow the view link for data file "sample.txt"
    Then I should see details displayed
      | Name            | sample.txt            |
      | Date added      | 2011-12-01 13:45      |
      | Added by        | sean@intersect.org.au |
      | Start time      | 2010-06-01  6:42:01   |
      | End time        | 2011-11-30 18:05:23   |
      | Sample Interval | 5 minutes             |

  Scenario: View a data file with no start/end times
    When I am on the data file details page for datafile.dat
    Then I should see details displayed
      | Name        | datafile.dat              |
      | Date added  | 2011-11-30 10:15          |
      | Added by    | georgina@intersect.org.au |
      | File format | Unknown                   |

  Scenario: Navigate back to the list
    When I am on the data file details page for sample.txt
    And I follow "Back"
    Then I should be on the list data files page

  Scenario: Must be logged in to view the details
    Then users should be required to login on the data file details page for sample.txt

  Scenario: TOA5 file shows mapped station name
    Given I have facilities
      | name        | code  |
      | WTC Station | WTC01 | 
    And I upload "WTC01_Table1.dat" through the applet
    When I am on the list data files page
    And I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Station name | WTC Station |

  Scenario: TOA5 file shows station code if no mapping to facility exists
    Given I upload "WTC01_Table1.dat" through the applet
    When I am on the list data files page
    And I follow the view link for data file "WTC01_Table1.dat"
    Then I should see details displayed
      | Station name | WTC01 |

  Scenario: TOA5 file shows correctly mapped column names in file info table
    Given I upload "Test_Column_Table.dat" through the applet
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
    Given I upload "Test_Column_Table.dat" through the applet
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
    Given I upload "Test_Column_Table.dat" through the applet
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
    Given I upload "Test_Column_Table.dat" through the applet
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

  Scenario: Fill in missing column mappings with invalid information
    Given I upload "Test_Column_Table.dat" through the applet
    When I am on the list data files page
    And I follow the view link for data file "Test_Column_Table.dat"
    And I follow "Fill in column mappings"
    And I press "Submit Column Mappings"
    Then I should see "Name can't be blank"




