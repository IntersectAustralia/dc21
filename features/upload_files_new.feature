Feature: Upload files
  In order to manage my data
  As a user
  I want to upload a file

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And I am logged in as "researcher@intersect.org.au"
    And I have facility "ROS Weather Station" with code "ROS_WS"
    And I have experiment "My Experiment" which belongs to facility "ROS_WS"

  Scenario: Browse widget doesn't appear until a type and experiment are selected

  Scenario: Browse widget goes away if type or experiment are unselected

#@javascript

  Scenario: Upload a single file
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/sample1.txt" to upload
    And I press "Upload"
    Then the uploaded files display should include "sample1.txt" with details
      | File type | Experiment    | Messages                   |
      | RAW       | My Experiment | File uploaded successfully |
    And the most recent file should have name "sample1.txt"
    And the "sample1.txt" should have type "RAW"
    And the "sample1.txt" should have experiment "My Experiment"

  Scenario: Upload multiple files

  Scenario: Upload more files after a first set (retains all file info and entered form values)

  Scenario: Modify and save metadata after uploading

  Scenario Outline: Possible outcomes for uploaded files
    Given I have uploaded "samples/subsetted/range_oct_10_oct_12/weather_stations_15_min.dat" with type "RAW"
    Given I have uploaded "samples/sample1.txt" with type "RAW"
    Given I am on the upload page
    When I select "<type>" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "<file path>" to upload
    And I press "Upload"
    Then the uploaded files display should include "<resulting name>" with details
      | File type | Experiment    | Messages   |
      | <type>    | My Experiment | <messages> |
    And the most recent file should have name "<resulting name>"
    And the "<resulting name>" should have type "<resulting type>"
    And the "<resulting name>" should have experiment "My Experiment"
    And there should be <resulting file count> files in the system


  Examples:
    | type      | messages | resulting name                            | resulting type | resulting file count | description                                         | file path                                                                                |
    | RAW       | success  | weather_station_15_min_oct_13_15.dat      | RAW            | 3                    | no overlap, different file name                     | samples/subsetted/range_oct_13_oct_15_renamed/weather_station_15_min_oct_13_15.dat       |
    | RAW       | success  | weather_station_15_min_1.dat              | RAW            | 3                    | no overlap, clashing file name                      | samples/subsetted/range_oct_13_oct_15/weather_station_15_min.dat                         |
    | RAW       | success  | weather_station_15_min_oct_10_onwards.dat | RAW            | 2                    | safe overlap, different file name                   | samples/subsetted/range_oct_10_onwards_renamed/weather_station_15_min_oct_10_onwards.dat |
    | RAW       | success  | weather_station_15_min_1.dat              | RAW            | 2                    | safe overlap, replacing file of same name           | samples/subsetted/range_oct_10_onwards/weather_station_15_min.dat                        |
    | RAW       | success  | sample1_1.txt                             | RAW            | 2                    | safe overlap, clashing file name                    | samples/subsetted/range_oct_10_onwards_renamed/sample1.txt                               |
    | RAW       | success  | weather_station_15_min_oct_14_16.dat      | ERROR          | 3                    | bad overlap, different file name                    | samples/subsetted/range_oct_14_oct_16/weather_station_15_min_oct_14_16.dat               |
    | RAW       | success  | weather_station_15_min_1.dat              | ERROR          | 3                    | bad overlap, clashing file name                     | samples/subsetted/range_oct_14_oct_16/weather_station_15_min.dat                         |
    | RAW       | success  | sample2.txt                               | RAW            | 3                    | non-TOA5, different file name                       | samples/sample2.txt                                                                      |
    | RAW       | success  | sample1_1.dat                             | RAW            | 3                    | non-TOA5, clashing file name                        | samples/sample1.txt                                                                      |
    | PROCESSED | success  | weather_station_15_min_oct_10_onwards.dat | PROCESSED      | 3                    | safe overlap, but not marked raw                    | samples/subsetted/range_oct_10_onwards_renamed/weather_station_15_min_oct_10_onwards.dat |
    | PROCESSED | success  | weather_station_15_min_1.dat              | PROCESSED      | 3                    | safe overlap, but not marked raw, clashing filename | samples/subsetted/range_oct_10_onwards/weather_station_15_min.dat                        |


  Scenario: Must be logged in to view the upload page
    Then users should be required to login on the upload page

  Scenario: Must be logged in to upload
    Given I am on the upload page
    When I attempt to upload "sample1.txt" through the applet without an auth token I should get an error
