Feature: Upload files
  In order to manage my data
  As a user
  I want to upload a file

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And I have a user "administrator@intersect.org.au" with role "Administrator"
    And I am logged in as "researcher@intersect.org.au"
    And I have facility "ROS Weather Station" with code "ROS_WS"
    And I have facility "Flux Tower" with code "FLUX"
    And I am on the upload page
    And I upload "sample1.txt" through the applet as "researcher@intersect.org.au"

  Scenario: Upload a single file and ignore post processing
    Given I follow "Next"
    And I am on the set data file status page
    When I press "Done"
    Then I should be on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Added by                    | Start time | End time | Processing status |
      | sample1.txt | researcher@intersect.org.au |            |          | UNDEFINED         |
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Processing status | UNDEFINED |
      | Description       |           |

  Scenario: Assign a status only to a newly uploaded file
    Given I follow "Next"
    And I am on the set data file status page
    When I select "RAW" from the select box for "sample1.txt"
    And I press "Done"
    Then I should be on the list data files page
    And I should see "exploredata" table with
      | Filename    | Added by                    | Start time | End time | Processing status |
      | sample1.txt | researcher@intersect.org.au |            |          | RAW               |
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Processing status | RAW |
      | Description       |     |

  Scenario: Assign a description only to a newly uploaded file
    Given I follow "Next"
    And I am on the set data file status page
    When I fill in "file_processing_description" with "I don't understand why I uploaded this file" for "sample1.txt"
    And I press "Done"
    Then I should be on the list data files page
    And I should see "exploredata" table with
      | Filename    | Added by                    | Start time | End time | Processing status |
      | sample1.txt | researcher@intersect.org.au |            |          | UNDEFINED         |
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Processing status | UNDEFINED                                   |
      | Description       | I don't understand why I uploaded this file |

  Scenario: Assign a status and description to a newly uploaded file
    Given I follow "Next"
    And I am on the set data file status page
    When I select "RAW" from the select box for "sample1.txt"
    And I fill in "file_processing_description" with "Raw sample file" for "sample1.txt"
    And I press "Done"
    Then I should be on the list data files page
    And I should see "exploredata" table with
      | Filename    | Added by                    | Start time | End time | Processing status |
      | sample1.txt | researcher@intersect.org.au |            |          | RAW               |
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Processing status | RAW             |
      | Description       | Raw sample file |
      | Experiment        |                 |

  Scenario: Assign the experiment for a newly uploaded file
    Given I have experiments
      | name              | facility            |
      | Wind Experiment   | ROS Weather Station |
      | Rain Experiment   | ROS Weather Station |
      | Flux Experiment 1 | Flux Tower          |
      | Flux Experiment 2 | Flux Tower          |
      | Flux Experiment 3 | Flux Tower          |
    When I upload "toa5.dat" through the applet
    And I follow "Next"
    Then the experiment select for "sample1.txt" should contain
      | Flux Tower          | Flux Experiment 1, Flux Experiment 2, Flux Experiment 3 |
      | ROS Weather Station | Rain Experiment,  Wind Experiment                       |
      | Other               | Other                                                   |
    And the experiment select for "toa5.dat" should contain
      | ROS Weather Station | Rain Experiment,  Wind Experiment                       |
      | Flux Tower          | Flux Experiment 1, Flux Experiment 2, Flux Experiment 3 |
      | Other               | Other                                                   |
    When I select "Wind Experiment" as the experiment for "toa5.dat"
    When I press "Done"
    And I follow the view link for data file "toa5.dat"
    Then I should see details displayed
      | Experiment | Wind Experiment |

  Scenario: Can assign the "Other" experiment to a file
    Given I have experiments
      | name            | facility            |
      | Wind Experiment | ROS Weather Station |
      | Rain Experiment | ROS Weather Station |
    When I follow "Next"
    When I select "Other" as the experiment for "sample1.txt"
    When I press "Done"
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Experiment | Other |

  Scenario: Experiment should be pre-selected when file is linked to a facility and the facility has only one experiment
    Given I have experiments
      | name              | facility            |
      | Wind Experiment   | ROS Weather Station |
      | Flux Experiment 1 | Flux Tower          |
      | Flux Experiment 2 | Flux Tower          |
      | Flux Experiment 3 | Flux Tower          |
    When I upload "toa5.dat" through the applet
    And I follow "Next"
    Then "Wind Experiment" should be selected in the experiment select for "toa5.dat"

  Scenario: Assign a status and description to only one of two newly uploaded files
    Given I upload "sample2.txt" through the applet as "researcher@intersect.org.au"
    Given I follow "Next"
    And I am on the set data file status page
    When I select "RAW" from the select box for "sample1.txt"
    And I fill in "file_processing_description" with "Raw sample file" for "sample1.txt"
    And I press "Done"
    Then I should be on the list data files page
    And I should see "exploredata" table with
      | Filename    | Added by                    | Start time | End time | Processing status |
      | sample2.txt | researcher@intersect.org.au |            |          | UNDEFINED         |
      | sample1.txt | researcher@intersect.org.au |            |          | RAW               |
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Processing status | RAW             |
      | Description       | Raw sample file |
    And I follow "Explore Data"
    And I follow the view link for data file "sample2.txt"
    Then I should see details displayed
      | Processing status | UNDEFINED |
      | Description       |           |


  Scenario: Ensure the 'processing metadata is set for files as follows:' meta step definition works
    Given I have data files
      | filename     | created_at       | uploaded_by                 | start_time | end_time |
      | datafile.dat | 30/11/2011 10:15 | researcher@intersect.org.au |            |          |
    And The processing metadata is set for files as follows:
      | filename     | status | description   |
      | datafile.dat | RAW    | something set |
    And I should see "exploredata" table with
      | Filename     | Added by                    | Start time | End time | Processing status |
      | sample1.txt  | researcher@intersect.org.au |            |          | UNDEFINED         |
      | datafile.dat | researcher@intersect.org.au |            |          | RAW               |
    And I follow the view link for data file "datafile.dat"
    Then I should see details displayed
      | Processing status | RAW           |
      | Description       | something set |


  @wip
  Scenario: Assign a status and description to multiple existing uploaded files
    When I press "Done"
    Then I should be on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Added by                    | Start time | End time | Processing status | Description |
      | sample1.txt | researcher@intersect.org.au |            |          |                   |             |


#until we can use cucumber with the applet

  @wip
  Scenario: Upload the same file twice
    Given I am on the upload page
    When I upload "sample1.txt" through the applet
    When I upload "sample1.txt" through the applet
    Then I should see "sample1.txt - This file already exists."

  Scenario: Must be logged in to view the upload page
    Then users should be required to login on the upload page

  Scenario: Must be logged in to upload
    Given I am on the upload page
    When I attempt to upload "sample1.txt" through the applet without an auth token I should get an error
