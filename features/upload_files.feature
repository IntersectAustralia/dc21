Feature: Upload files
  In order to manage my data
  As a user
  I want to upload a file

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Institutional User"
    And I have a user "admin@intersect.org.au" with role "Administrator"
    And I am logged in as "researcher@intersect.org.au"
    And I have facility "ROS Weather Station" with code "ROS_WS"
    And I have facility "Flux Tower" with code "FLUX"
    And I have facility "Other" with code "Other Code"
    Given I have experiments
      | name              | facility            |
      | My Experiment     | ROS Weather Station |
      | Rain Experiment   | ROS Weather Station |
      | Flux Experiment 1 | Flux Tower          |
      | Flux Experiment 2 | Flux Tower          |
      | Flux Experiment 3 | Flux Tower          |
      | Other             | Other               |
    And I have tags
      | name       |
      | Photo      |
      | Video      |
      | Gap-Filled |

  @javascript
  Scenario: Additional file select box appears after previous one is used
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    And I select "samples/sample1.txt" to upload with "files_field_0"
    And I select "samples/sample2.txt" to upload with "files_field_1"
    And I press "Upload"
    And the uploaded files display should include "sample1.txt" with file type "RAW"
    And the uploaded files display should include "sample1.txt" with messages "success"
    And the uploaded files display should include "sample1.txt" with experiment "My Experiment"
    And the uploaded files display should include "sample2.txt" with file type "RAW"
    And the uploaded files display should include "sample2.txt" with messages "success"
    And the uploaded files display should include "sample2.txt" with experiment "My Experiment"

  Scenario: Try to upload without selecting any files
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    And I press "Upload"
    Then I should see "Please select at least one file to upload"
    And "RAW" should be selected in the "File type" select
    And "My Experiment" should be selected in the "Experiment" select
    And the "Video" checkbox should be checked

  Scenario: Try to upload without selecting an experiment
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "samples/sample1.txt" to upload
    And I press "Upload"
    Then I should see "Please select an experiment"
    And "RAW" should be selected in the "File type" select

  Scenario: Try to upload without selecting a file type
    Given I am on the upload page
    And I select "My Experiment" from "Experiment"
    And I select "samples/sample1.txt" to upload
    And I press "Upload"
    Then I should see "Please select the file type"
    And "My Experiment" should be selected in the "Experiment" select

  Scenario: Experiment select contains the appropriate items
    Given I am on the upload page
    Then the experiment select should contain
      | Flux Tower          | Flux Experiment 1, Flux Experiment 2, Flux Experiment 3 |
      | Other               | Other                                                   |
      | ROS Weather Station | My Experiment,  Rain Experiment                         |

  Scenario: Tag checkboxes contain the appropriate items
    Given I am on the upload page
    Then I should see tag checkboxes
      | Gap-Filled |
      | Photo      |
      | Video      |

  Scenario: Upload a single file
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I check "Gap-Filled"
    And I press "Upload"
    Then the most recent file should have name "sample1.txt"
    And the uploaded files display should include "sample1.txt" with file type "RAW"
    And the uploaded files display should include "sample1.txt" with messages "success"
    And the uploaded files display should include "sample1.txt" with experiment "My Experiment"
    And the uploaded files display should include "sample1.txt" with description "My descriptive description"
    And the uploaded files display should include "sample1.txt" with tags "Gap-Filled, Photo"
    And file "sample1.txt" should have type "RAW"
    And file "sample1.txt" should have experiment "My Experiment"
    And file "sample1.txt" should have tags "Gap-Filled,Photo"
    And file "sample1.txt" should have description "My descriptive description"
    When I am on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Added by                    | Type |
      | sample1.txt | researcher@intersect.org.au | RAW  |
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Type        | RAW                        |
      | Description | My descriptive description |
      | Experiment  | My Experiment              |
      | Tags        | Gap-Filled\nPhoto          |

  Scenario: Upload a single file with no tags or description
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/sample1.txt" to upload
    And I press "Upload"
    Then the most recent file should have name "sample1.txt"
    And the uploaded files display should include "sample1.txt" with file type "RAW"
    And the uploaded files display should include "sample1.txt" with messages "success"
    And the uploaded files display should include "sample1.txt" with experiment "My Experiment"
    And the uploaded files display should include "sample1.txt" with description ""
    And the uploaded files display should include "sample1.txt" with tags ""
    And file "sample1.txt" should have type "RAW"
    And file "sample1.txt" should have experiment "My Experiment"
    When I am on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Added by                    | Type |
      | sample1.txt | researcher@intersect.org.au | RAW  |
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Type        | RAW           |
      | Description |               |
      | Experiment  | My Experiment |
      | Tags        |               |

  Scenario: Upload multiple files
# This cannot be automated due to limitations with selenium+file uploads - see manual tests

  Scenario: Modify and save metadata after uploading
    Given I upload "samples/subsetted/range_oct_10_oct_12/weather_station_15_min.dat" with type "RAW" and description "new description" and experiment "My Experiment" and tags "Video"
    And I select "Flux Experiment 1" from "Experiment" within the file area for 'weather_station_15_min.dat'
    And I fill in "Description" with "I'm changing the description" within the file area for 'weather_station_15_min.dat'
    And I check "Photo" within the file area for 'weather_station_15_min.dat'
    And I check "Gap-Filled" within the file area for 'weather_station_15_min.dat'
    And I uncheck "Video" within the file area for 'weather_station_15_min.dat'
    And I press "Update"
    Then I should be on the home page
    When I am on the list data files page
    Then I should see "exploredata" table with
      | Filename                   | Added by                    | Type |
      | weather_station_15_min.dat | researcher@intersect.org.au | RAW  |
    And I follow the view link for data file "weather_station_15_min.dat"
    Then I should see details displayed
      | Type             | RAW                           |
      | Description      | I'm changing the description  |
      | Experiment       | Flux Experiment 1             |
      | Tags             | Gap-Filled\nPhoto             |
      | Start time       | 2011-10-10  0:00:00           |
      | End time         | 2011-10-12 23:45:00           |
      | Sample interval  | 15 minutes                    |
      | Datalogger model | CR3000                        |
      | Station name     | ROS_WS                        |
      | Serial number    | 4909                          |
      | Os version       | CR3000.Std.11                 |
      | Dld name         | CPU:weather_station_final.CR3 |
      | Dld signature    | 30238                         |
      | Table name       | Table15min                    |

  Scenario: Modify and save metadata after uploading (multiple files)
# This cannot be automated due to limitations with selenium+file uploads - see manual tests

  Scenario Outline: Possible outcomes for uploaded files (without overlap)
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
    | type      | messages                                  | resulting name                            | resulting type | resulting file count | description                                         | file path                                                                                |
    | RAW       | success                                   | weather_station_15_min_oct_13_15.dat      | RAW            | 3                    | no overlap, different file name                     | samples/subsetted/range_oct_13_oct_15_renamed/weather_station_15_min_oct_13_15.dat       |
    | RAW       | renamed                                   | weather_station_15_min_1.dat              | RAW            | 3                    | no overlap, clashing file name                      | samples/subsetted/range_oct_13_oct_15/weather_station_15_min.dat                         |
    | RAW       | badoverlap                                | weather_station_15_min_oct_11_13.dat      | ERROR          | 3                    | bad overlap, different file name                    | samples/subsetted/range_oct_11_oct_13/weather_station_15_min_oct_11_13.dat               |
    | RAW       | renamed, badoverlap                       | weather_station_15_min_1.dat              | ERROR          | 3                    | bad overlap, clashing file name                     | samples/subsetted/range_oct_11_oct_13/weather_station_15_min.dat                         |
    | RAW       | success                                   | sample2.txt                               | RAW            | 3                    | non-TOA5, different file name                       | samples/sample2.txt                                                                      |
    | RAW       | renamed                                   | sample1_1.txt                             | RAW            | 3                    | non-TOA5, clashing file name                        | samples/sample1.txt                                                                      |
    | PROCESSED | success                                   | weather_station_15_min_oct_10_onwards.dat | PROCESSED      | 3                    | safe overlap, but not marked raw                    | samples/subsetted/range_oct_10_onwards_renamed/weather_station_15_min_oct_10_onwards.dat |
    | PROCESSED | renamed                                   | weather_station_15_min_1.dat              | PROCESSED      | 3                    | safe overlap, but not marked raw, clashing filename | samples/subsetted/range_oct_10_onwards/weather_station_15_min.dat                        |

  Scenario Outline: Possible outcomes for uploaded files (with overlap)
    Given I have uploaded "subsetted/range_oct_10_oct_12/weather_station_15_min.dat" with type "RAW"
    Given I have uploaded "sample1.txt" with type "RAW"
    Given I am on the upload page
    When I select "<type>" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "<file path>" to upload
    And I press "Upload"
    Then the most recent file should have name "<resulting name>"
    And the uploaded files display should include "<resulting name>" with messages "<messages>"
    And file "<resulting name>" should have type "<resulting type>"
    And file "<resulting name>" should have experiment "My Experiment"
    And file "<resulting name>" should have description "My descriptive description"
    And there should be <resulting file count> files in the system

  Examples:
    | type      | messages                                  | resulting name                            | resulting type | resulting file count | description                                         | file path                                                                                |
    | RAW       | goodoverlap, ownership_inherited          | weather_station_15_min_oct_10_onwards.dat | RAW            | 2                    | safe overlap, different file name                   | samples/subsetted/range_oct_10_onwards_renamed/weather_station_15_min_oct_10_onwards.dat |
    | RAW       | goodoverlap, ownership_inherited          | weather_station_15_min.dat                | RAW            | 2                    | safe overlap, replacing file of same name           | samples/subsetted/range_oct_10_onwards/weather_station_15_min.dat                        |
    | RAW       | goodoverlap, renamed, ownership_inherited | sample1_1.txt                             | RAW            | 2                    | safe overlap, clashing file name                    | samples/subsetted/range_oct_10_onwards_renamed/sample1.txt                               |

  Scenario: Upload multiple files where there's an overlap or name clash within the set of files being uploaded
# This cannot be automated due to limitations with selenium+file uploads - see manual tests

  Scenario: Must be logged in to view the upload page
    Then users should be required to login on the upload page

  Scenario: Must be logged in to upload
    Given I am on the upload page
    When I attempt to upload "sample1.txt" directly I should get an error

  Scenario: Provide Metadata for uploaded non-toa5 files
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I press "Upload"
    Then I should be on the data files page
    And I should see "Experiment" for file "sample1.txt"
    And I should see "Description" for file "sample1.txt"
    And I should see "start_time" for file "sample1.txt"
    And I should see "end_time" for file "sample1.txt"

  Scenario: Non-toa5 metadata fields should not appear for toa5 files in bulk update
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/toa5.dat" to upload
    And I press "Upload"
    Then I should be on the data files page
    And I should not see "start_time" for file "toa5.dat"
    And I should not see "end_time" for file "toa5.dat"

  Scenario: Provide Metadata for uploaded non-toa5 files
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I press "Upload"
    Then I should be on the data files page
    And I fill in "2010-06-03" for "Start Time"
    And I fill in "2010-06-10" for "End Time"
    And I press "Update"
    Then I should be on the home page
    And the most recent file should have name "sample1.txt"

    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Start time | 2010-06-03  0:00:00 |
      | End time   | 2010-06-10  0:00:00 |


  Scenario: Start Time is required if end Time specified
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I press "Upload"
    Then I should be on the data files page

    And I fill in "2010-06-10" for "End Time"
    And I press "Update"
    Then I should be on the bulk update page
    And I should see "Start time is required if End time specified"

  Scenario: End Time not required with start Time
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I press "Upload"
    Then I should be on the data files page

    And I fill in "2010-06-03" for "Start Time"
    And I press "Update"
    Then I should be on the home page
    And the most recent file should have name "sample1.txt"

    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Start time | 2010-06-03  0:00:00 |

  Scenario: Neither start Time nor end Time required for non-toa5 files
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I press "Upload"
    Then I should be on the data files page

    And I press "Update"
    Then I should be on the home page
    And the most recent file should have name "sample1.txt"

    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Start time | Unknown |

  @javascript

  Scenario: When entering a dates for non-toa5, i should also have the option of entering times
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I press "Upload"
    Then I should be on the data files page
    And I should see "start_time" for file "sample1.txt"
    And I should see "end_time" for file "sample1.txt"
    And I should not see "start_hr" for file "sample1.txt"
    And I should not see "end_hr" for file "sample1.txt"
    And I fill in "2010-06-03" for "Start Time"
    And I fill in "2010-06-10" for "End Time"
    And I click on "Start Time"
    And I click on "End Time"
    And I wait for 2 seconds
    Then I should see "start_hr" for file "sample1.txt"
    And I should see "start_min" for file "sample1.txt"
    And I should see "start_sec" for file "sample1.txt"
    And I should see "end_hr" for file "sample1.txt"
    And I should see "end_min" for file "sample1.txt"
    And I should see "end_sec" for file "sample1.txt"

  @javascript
  Scenario: When clearing a date for non-toa5, times should also be removed
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I press "Upload"
    And I fill in "2010-06-03" for "Start Time"
    And I fill in "2010-06-10" for "End Time"
    And I click on "Start Time"
    And I click on "End Time"
    And I wait for 2 seconds
    And I should see "start_hr" for file "sample1.txt"
    And I should see "end_hr" for file "sample1.txt"
    And I fill in "" for "Start Time"
    And I fill in "" for "End Time"
    And I click on "Start Time"
    And I click on "End Time"
    And I wait for 2 seconds
    Then I should not see "start_hr" for file "sample1.txt"
    And I should not see "start_min" for file "sample1.txt"
    And I should not see "start_sec" for file "sample1.txt"
    And I should not see "end_hr" for file "sample1.txt"
    And I should not see "end_min" for file "sample1.txt"
    And I should not see "end_sec" for file "sample1.txt"

  @javascript @wip
  Scenario: Dates and times for non-toa5 files are processed correctly
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I press "Upload"
    And I fill in "2010-06-03" for "Start Time"
    And I click on "Start Time"

    And I select "05" from "Start Hour"
    And I select "30" from "Start Min"
    And I select "45" from "Start Second"
    And I fill in "2010-06-10" for "End Time"
    And I click on "End Time"

    And I select "06" from "End Hour"
    And I select "31" from "End Min"
    And I select "44" from "End Second"
    And I press "Upload"

  Scenario: The date format is on the date files page after uploading a file
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I press "Upload"
    Then I should be on the data files page
    And I should see "yyyy-mm-dd"


  Scenario: Upload a single file multiple times
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I check "Gap-Filled"
    And I press "Upload"
    Then the most recent file should have name "sample1.txt"
    And the uploaded files display should include "sample1.txt" with file type "RAW"
    And the uploaded files display should include "sample1.txt" with messages "success"
    And the uploaded files display should include "sample1.txt" with experiment "My Experiment"
    And the uploaded files display should include "sample1.txt" with description "My descriptive description"
    And the uploaded files display should include "sample1.txt" with tags "Gap-Filled, Photo"
    And file "sample1.txt" should have type "RAW"
    And file "sample1.txt" should have experiment "My Experiment"
    And file "sample1.txt" should have tags "Gap-Filled,Photo"
    And file "sample1.txt" should have description "My descriptive description"
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I check "Gap-Filled"
    And I press "Upload"
    Then the most recent file should have name "sample1_1.txt"
    And the uploaded files display should include "sample1_1.txt" with file type "RAW"
    And the uploaded files display should include "sample1_1.txt" with messages "renamed"
    And the uploaded files display should include "sample1_1.txt" with experiment "My Experiment"
    And the uploaded files display should include "sample1_1.txt" with description "My descriptive description"
    And the uploaded files display should include "sample1_1.txt" with tags "Gap-Filled, Photo"
    And file "sample1_1.txt" should have type "RAW"
    And file "sample1_1.txt" should have experiment "My Experiment"
    And file "sample1_1.txt" should have tags "Gap-Filled,Photo"
    And file "sample1_1.txt" should have description "My descriptive description"
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I check "Photo"
    And I check "Gap-Filled"
    And I press "Upload"
    Then the most recent file should have name "sample1_2.txt"
    And the uploaded files display should include "sample1_2.txt" with file type "RAW"
    And the uploaded files display should include "sample1_2.txt" with messages "renamed"
    And the uploaded files display should include "sample1_2.txt" with experiment "My Experiment"
    And the uploaded files display should include "sample1_2.txt" with description "My descriptive description"
    And the uploaded files display should include "sample1_2.txt" with tags "Gap-Filled, Photo"
    And file "sample1_2.txt" should have type "RAW"
    And file "sample1_2.txt" should have experiment "My Experiment"
    And file "sample1_2.txt" should have tags "Gap-Filled,Photo"
    And file "sample1_2.txt" should have description "My descriptive description"

#EYETRACKER-88

  Scenario: Add new labels to file upload
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "data_file_label_list" with "bebba,Abba,cuba,AA<script></script>"
    And I select "samples/sample1.txt" to upload
    And I press "Upload"
    And the uploaded files display should include "sample1.txt" with labels "bebba,Abba,cuba,AA<script></script>"
    And I fill in "Labels" with "bebba|Abba"
    And I press "Update"
    And I am on the data file details page for sample1.txt
    Then I should see field "Labels" with value "Abba, bebba"

  Scenario: Add new contributors to file upload
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I fill in "data_file_contributor_list" with "bebba,Abba,cuba,AA<script></script>"
    And I select "samples/sample1.txt" to upload
    And I press "Upload"
    And the uploaded files display should include "sample1.txt" with contributors "bebba,Abba,cuba,AA<script></script>"
    And I fill in "Contributors" with "bebba|Abba"
    And I press "Update"
    And I am on the data file details page for sample1.txt
    Then file "sample1.txt" should have contributors "bebba,Abba"

#EYETRACKER-7

  Scenario: Check UUID is blank for uploaded none image files
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/sample1.txt" to upload
    And I press "Upload"
    Then the most recent file should have name "sample1.txt"
    And the uploaded files display should include "sample1.txt" with file type "RAW"
    And the uploaded files display should include "sample1.txt" with messages "success"
    And the uploaded files display should include "sample1.txt" with experiment "My Experiment"
    And file "sample1.txt" should have type "RAW"
    And file "sample1.txt" should have experiment "My Experiment"
    And file "sample1.txt" should not have a UUID created

  #EYETRACKER-7 EYETRACKER-8 EYETRACKER-138 EYETRACKER-140 EYETRACKER-169
  Scenario Outline: Check UUID created for uploaded image file conforming to autoprocessing config
    Given I logout
    And I have the following system configuration
      | auto_<type>_on_upload |
      | true                  |
    And I am logged in as "<email>"
    When I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/<file>" to upload
    And I press "Upload"
    Then the most recent file should have name "<file>.txt"
    And the uploaded files display should include "<file>" with file type "RAW"
    And the uploaded files display should include "<file>" with messages "success"
    And the uploaded files display should include "<file>" with experiment "My Experiment"
    And file "<file>" should have type "RAW"
    And file "<file>" should have experiment "My Experiment"
    And file "<file>.txt" should be created by "<email>"
    And file "<file>.txt" should have a UUID created
    And I am on the data file details page for <file>
    And I should not see "Creation status"
    And I should see details displayed
      | Parents  | No parent files defined. |
      | Children | <file>.txt               |
    When I am on the list data files page
    Then I should see "exploredata" table with
      | Filename   | Added by | Type      |
      | <file>.txt | <email>  | PROCESSED |
      | <file>     | <email>  | RAW       |

  Examples:
    | file         | email                       | type |
    | Test_OCR.jpg | admin@intersect.org.au      | ocr  |
    | Test_OCR.jpg | researcher@intersect.org.au | ocr  |
    | Test_OCR.png | admin@intersect.org.au      | ocr  |
    | Test_OCR.png | researcher@intersect.org.au | ocr  |
    | Test_SR.wav  | admin@intersect.org.au      | sr   |
    | Test_SR.wav  | researcher@intersect.org.au | sr   |
    | Test_SR.mp3  | admin@intersect.org.au      | sr   |
    | Test_SR.mp3  | researcher@intersect.org.au | sr   |

  #EYETRACKER-138
  Scenario: Check UUID is blank for uploaded image file not conforming to auto OCR processing config
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/Test_OCR.jpg" to upload
    And I press "Upload"
    Then the most recent file should have name "Test_OCR.jpg"
    And file "Test_OCR.jpg" should not have a UUID created
    When I logout
    And I am logged in as "admin@intersect.org.au"
    And I am on the edit system config page
    And I check "Auto OCR on Upload"
    And I select "image/bmp" from "system_configuration_supported_ocr_types"
    And I press "Update"
    And I am on the upload page
    And I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/Test_OCR.tiff" to upload
    And I press "Upload"
    Then the most recent file should have name "Test_OCR.tiff"
    And file "Test_OCR.tiff" should not have a UUID created
    When I am on the edit system config page
    And I uncheck "Auto OCR on Upload"
    And I press "Update"
    And I am on the upload page
    And I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/Test_OCR.jpg" to upload
    And I press "Upload"
    Then the most recent file should have name "Test_OCR_1.jpg"
    And file "Test_OCR_1.jpg" should not have a UUID created
    When I am on the edit system config page
    And I check "Auto OCR on Upload"
    And I fill in "Auto OCR Regular Expression" with "a"
    And I press "Update"
    And I am on the upload page
    And I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/Test_OCR.jpg" to upload
    And I press "Upload"
    Then the most recent file should have name "Test_OCR_2.jpg"
    And file "Test_OCR_2.jpg" should not have a UUID created

  #EYETRACKER-138
  Scenario: Check UUID is blank for uploaded audio file not conforming to auto SR processing config
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/Test_SR.mp3" to upload
    And I press "Upload"
    Then the most recent file should have name "Test_SR.mp3"
    And file "Test_SR.mp3" should not have a UUID created
    When I logout
    And I am logged in as "admin@intersect.org.au"
    And I am on the edit system config page
    And I check "Auto SR on Upload"
    And I select "audio/x-wav" from "system_configuration_supported_sr_types"
    And I press "Update"
    And I am on the upload page
    And I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/toa5.dat" to upload
    And I press "Upload"
    Then the most recent file should have name "toa5.dat"
    And file "toa5.dat" should not have a UUID created
    When I am on the edit system config page
    And I uncheck "Auto SR on Upload"
    And I select "audio/mpeg" from "system_configuration_supported_sr_types"
    And I press "Update"
    And I am on the upload page
    And I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/Test_SR.mp3" to upload
    And I press "Upload"
    Then the most recent file should have name "Test_SR_1.mp3"
    And file "Test_SR_1.mp3" should not have a UUID created
    When I am on the edit system config page
    And I check "Auto SR on Upload"
    And I fill in "Auto SR Regular Expression" with "a"
    And I press "Update"
    And I am on the upload page
    And I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/Test_SR.mp3" to upload
    And I press "Upload"
    Then the most recent file should have name "Test_SR_2.mp3"
    And file "Test_SR_2.mp3" should not have a UUID created

  #EYETRACKER-186
  Scenario Outline: Regular expression matching should be case insensitive
    Given I logout
    And I have the following system configuration
      | auto_<type>_on_upload | auto_<type>_regex |
      | true                  | tEST              |
    And I am logged in as "<email>"
    When I am on the upload page
    And I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And I select "samples/<file>" to upload
    And I press "Upload"
    Then the most recent file should have name "<file>.txt"
    And file "<file>.txt" should be created by "<email>"
    And file "<file>.txt" should have a UUID created
  Examples:
    | file         | email                       | type |
    | Test_OCR.jpg | admin@intersect.org.au      | ocr  |
    | Test_OCR.jpg | researcher@intersect.org.au | ocr  |
    | Test_SR.wav  | admin@intersect.org.au      | sr   |
    | Test_SR.wav  | researcher@intersect.org.au | sr   |

  #UWSHIEVMOD-131
  Scenario: Creator is the logged in user by default and changeable
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "My Experiment" from "Experiment"
    And "Fred Bloggs (researcher@intersect.org.au)" should be selected for "Creator"
    And I select "samples/sample1.txt" to upload
    And I press "Upload"
    Then "Fred Bloggs (researcher@intersect.org.au)" should be selected for "Creator"
    And I select "Fred Bloggs (admin@intersect.org.au)" from the creator select box
    And I press "Update"
    And I am on the data file details page for sample1.txt
    Then I should see field "Creator" with value "Fred Bloggs (admin@intersect.org.au)"