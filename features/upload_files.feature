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
    And I have uploaded "sample1.txt" as "researcher@intersect.org.au"

  Scenario: Assign the experiment for a newly uploaded file
    Given I have experiments
      | name              | facility            |
      | Wind Experiment   | ROS Weather Station |
      | Rain Experiment   | ROS Weather Station |
      | Flux Experiment 1 | Flux Tower          |
      | Flux Experiment 2 | Flux Tower          |
      | Flux Experiment 3 | Flux Tower          |
    When I have uploaded "toa5.dat"
    And I follow "Next"
    Then the experiment select for "sample1.txt" should contain
      | Flux Tower          | Flux Experiment 1, Flux Experiment 2, Flux Experiment 3 |
      | ROS Weather Station | Rain Experiment,  Wind Experiment                       |
      | Other               | Other                                                   |
    And the experiment select for "toa5.dat" should contain
      | ROS Weather Station | Rain Experiment,  Wind Experiment                       |
    When I select "Wind Experiment" as the experiment for "toa5.dat"
    When I press "Done"
    And I follow the view link for data file "toa5.dat"
    Then I should see details displayed
      | Experiment | Wind Experiment |


  Scenario: Experiment should be pre-selected when file is linked to a facility and the facility has only one experiment
    Given I have experiments
      | name              | facility            |
      | Wind Experiment   | ROS Weather Station |
      | Flux Experiment 1 | Flux Tower          |
      | Flux Experiment 2 | Flux Tower          |
      | Flux Experiment 3 | Flux Tower          |
    When I have uploaded "toa5.dat"
    And I follow "Next"
    Then "Wind Experiment" should be selected in the experiment select for "toa5.dat"
