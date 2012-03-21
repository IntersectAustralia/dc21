Feature: Upload files
  In order to manage my data
  As a user
  I want to upload a file

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And I am logged in as "researcher@intersect.org.au"
    And I have facility "ROS Weather Station" with code "ROS_WS"
    And I have facility "Flux Tower" with code "FLUX"
    Given I have experiments
      | name              | facility            |
      | My Experiment     | ROS Weather Station |
      | Rain Experiment   | ROS Weather Station |
      | Flux Experiment 1 | Flux Tower          |
      | Flux Experiment 2 | Flux Tower          |
      | Flux Experiment 3 | Flux Tower          |

  Scenario: Browse widget doesn't appear until a type and experiment are selected
    Given pending

  Scenario: Browse widget goes away if type or experiment are unselected
    Given pending

  Scenario: Additional file select box appears after previous one is used
    Given pending

  Scenario: Try to upload without selecting any files
    Given pending

  Scenario: Experiment select contains the appropriate items
    Given I am on the upload page
    Then the experiment select should contain
      | Flux Tower          | Flux Experiment 1, Flux Experiment 2, Flux Experiment 3 |
      | ROS Weather Station | My Experiment,  Rain Experiment                         |
      | Other               | Other                                                   |

  Scenario: Upload a single file
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I press "Upload"
    Then the most recent file should have name "sample1.txt"
    And the uploaded files display should include "sample1.txt" with file type "RAW"
    And the uploaded files display should include "sample1.txt" with messages "success"
    And the uploaded files display should include "sample1.txt" with experiment "My Experiment"
    And the uploaded files display should include "sample1.txt" with description "My descriptive description"
    And file "sample1.txt" should have type "RAW"
    And file "sample1.txt" should have experiment "My Experiment"
    When I am on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Added by                    | Start time | End time | Processing status |
      | sample1.txt | researcher@intersect.org.au |            |          | RAW               |
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Processing status | RAW                        |
      | Description       | My descriptive description |
      | Experiment        | My Experiment              |

  Scenario: Upload multiple files
    Given pending

  Scenario: Modify and save metadata after uploading
    Given I upload "samples/subsetted/range_oct_10_oct_12/weather_station_15_min.dat" with type "RAW" and description "new description" and experiment "My Experiment"
    And I select "Flux Experiment 1" from "Experiment" within the file area for 'weather_station_15_min.dat'
    And I fill in "Description" with "I'm changing the description" within the file area for 'weather_station_15_min.dat'
    And I press "Update"
    Then I should be on the home page
    When I am on the list data files page
    Then I should see "exploredata" table with
      | Filename                   | Added by                    | Start time          | End time            | Processing status |
      | weather_station_15_min.dat | researcher@intersect.org.au | 2011-10-10  0:00:00 | 2011-10-12 23:45:00 | RAW               |
    And I follow the view link for data file "weather_station_15_min.dat"
    Then I should see details displayed
      | Processing status | RAW                          |
      | Description       | I'm changing the description |
      | Experiment        | Flux Experiment 1            |


  Scenario: Modify and save metadata after uploading (multiple files)
    Given pending

  Scenario Outline: Possible outcomes for uploaded files
    Given I have uploaded "subsetted/range_oct_10_oct_12/weather_station_15_min.dat" with type "RAW"
    Given I have uploaded "sample1.txt" with type "RAW"
    Given I am on the upload page
    When I select "<type>" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "<file path>" to upload
    And I press "Upload"
    Then the most recent file should have name "<resulting name>"
    And the uploaded files display should include "<resulting name>" with file type "<resulting type>"
    And the uploaded files display should include "<resulting name>" with experiment "My Experiment"
    And the uploaded files display should include "<resulting name>" with messages "<messages>"
    And file "<resulting name>" should have type "<resulting type>"
    And file "<resulting name>" should have experiment "My Experiment"
    And file "<resulting name>" should have description "My descriptive description"
    And there should be <resulting file count> files in the system

  Examples:
    | type      | messages             | resulting name                            | resulting type | resulting file count | description                                         | file path                                                                                |
    | RAW       | success              | weather_station_15_min_oct_13_15.dat      | RAW            | 3                    | no overlap, different file name                     | samples/subsetted/range_oct_13_oct_15_renamed/weather_station_15_min_oct_13_15.dat       |
    | RAW       | renamed              | weather_station_15_min_1.dat              | RAW            | 3                    | no overlap, clashing file name                      | samples/subsetted/range_oct_13_oct_15/weather_station_15_min.dat                         |
    | RAW       | goodoverlap          | weather_station_15_min_oct_10_onwards.dat | RAW            | 2                    | safe overlap, different file name                   | samples/subsetted/range_oct_10_onwards_renamed/weather_station_15_min_oct_10_onwards.dat |
    | RAW       | goodoverlap          | weather_station_15_min.dat                | RAW            | 2                    | safe overlap, replacing file of same name           | samples/subsetted/range_oct_10_onwards/weather_station_15_min.dat                        |
    | RAW       | goodoverlap, renamed | sample1_1.txt                             | RAW            | 2                    | safe overlap, clashing file name                    | samples/subsetted/range_oct_10_onwards_renamed/sample1.txt                               |
    | RAW       | badoverlap           | weather_station_15_min_oct_11_13.dat      | ERROR          | 3                    | bad overlap, different file name                    | samples/subsetted/range_oct_11_oct_13/weather_station_15_min_oct_11_13.dat               |
    | RAW       | renamed, badoverlap  | weather_station_15_min_1.dat              | ERROR          | 3                    | bad overlap, clashing file name                     | samples/subsetted/range_oct_11_oct_13/weather_station_15_min.dat                         |
    | RAW       | success              | sample2.txt                               | RAW            | 3                    | non-TOA5, different file name                       | samples/sample2.txt                                                                      |
    | RAW       | renamed              | sample1_1.txt                             | RAW            | 3                    | non-TOA5, clashing file name                        | samples/sample1.txt                                                                      |
    | PROCESSED | success              | weather_station_15_min_oct_10_onwards.dat | PROCESSED      | 3                    | safe overlap, but not marked raw                    | samples/subsetted/range_oct_10_onwards_renamed/weather_station_15_min_oct_10_onwards.dat |
    | PROCESSED | renamed              | weather_station_15_min_1.dat              | PROCESSED      | 3                    | safe overlap, but not marked raw, clashing filename | samples/subsetted/range_oct_10_onwards/weather_station_15_min.dat                        |

  Scenario: Upload multiple files where there's an overlap or name clash within the set of files being uploaded
    Given pending

  Scenario: Must be logged in to view the upload page
    Then users should be required to login on the upload page

  Scenario: Must be logged in to upload
    Given I am on the upload page
    When I attempt to upload "sample1.txt" directly I should get an error

  Scenario: Can assign the "Other" experiment to a file
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "Other" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I press "Upload"
    Then the most recent file should have name "sample1.txt"
    And the uploaded files display should include "sample1.txt" with file type "RAW"
    And the uploaded files display should include "sample1.txt" with experiment "Other"
    And the uploaded files display should include "sample1.txt" with messages "success"
    And file "sample1.txt" should have type "RAW"
    And file "sample1.txt" should have experiment "Other"
    When I am on the list data files page
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Experiment | Other |
