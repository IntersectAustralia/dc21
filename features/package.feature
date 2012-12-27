@javascript

Feature: Create a package
  In order to handle multiple data files which belong to a group
  As a user
  I want to bundle them into a package for upload/download

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have facility "ROS Weather Station" with code "ROS_WS"
    And I have facility "Flux Tower" with code "FLUX"
    And I have data files
      | filename     |
      | datafile.dat |
      | sample.txt   |
      | sample2.txt  |
    And I have experiments
      | name              | facility            |
      | My Experiment     | ROS Weather Station |
      | Rain Experiment   | ROS Weather Station |
      | Flux Experiment 1 | Flux Tower          |
      | Flux Experiment 2 | Flux Tower          |
      | Flux Experiment 3 | Flux Tower          |
    And I have tags
      | name       |
      | Photo      |
      | Video      |
      | Gap-Filled |

  Scenario: Package is now available as a file type to search on
    Given I am on the list data files page
    And I click on "Type:"
    Then I should see "PACKAGE"

  Scenario: New package
    Given I am on the list data files page
    And I add sample.txt to the cart
    And I add datafile.dat to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Filename" with "my_package"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    And I press "Save"
    Then I should see "Package was successfully created."

  Scenario: New package - empty form submission
    Given I am on the list data files page
    And I add sample.txt to the cart
    And I add datafile.dat to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I press "Save"
    Then I should see "Please provide a filename"
    And I should see "Please select an experiment"

  Scenario: New package - rendering correct data_file view screen
    Given I am on the list data files page
    And I add sample.txt to the cart
    And I add datafile.dat to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Filename" with "my_other_package"
    And I fill in "Description" with "Here's a description"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    And I press "Save"
    When I am on the data file details page for my_other_package.zip
    Then I should see details displayed
      | Name  | my_other_package.zip   |
      | Type        | PACKAGE |
      | File format | BAGIT   |
      | Description | Here's a description   |
      | Experiment  | My Experiment   |





