Feature: Download multiple files
  In order to get hold of the data I'm interested in
  As a user
  I want to download multiple files from the explore data page

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have data files
      | filename    | created_at       | uploaded_by               | start_time       | end_time            | path                | id |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample1.txt | 1  |
      | sample2.txt | 30/11/2011 10:15 | georgina@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample2.txt | 2  |
      | sample3.txt | 30/12/2011 12:34 | georgina@intersect.org.au |                  |                     | samples/sample3.txt | 3  |
    And I am on the list data files page

  Scenario: Download a selection of files from the cart
    When I add "sample1.txt" to the cart
    And I add "sample2.txt" to the cart
    And I click on "Download"
    Then I should get a file with name "sample1.txt.zip" and content type "application/zip"
    And I should receive a zip file matching "samples/zip"

  Scenario: Download a single file from the cart
    When I add "sample1.txt" to the cart
    And I click on "Download"
    Then I should get a file with name "sample1.txt" and content type "text/plain"
    And the file should contain "Plain text file sample1.txt"

  Scenario: Downloading regular file requires log in
    Given I follow "Sign out"
    And I am on the data file download page for sample1.txt
    And I should see "You need to log in before continuing."

  Scenario: Downloading unpublished package requires log in
    Given I have facility "ROS Weather Station" with code "ROS_WS"
    And I have experiments
      | name              | facility            |
      | My Experiment     | ROS Weather Station |
    And I add "sample1.txt" to the cart
    And I add "sample2.txt" to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Filename" with "my_package"
    And I select "My Experiment" from "Experiment"
    And I press "Save"
    Then I should see "Package was successfully created."
    And I follow "Sign out"
    And I am on the data file download page for my_package.zip
    And I should see "You need to log in before continuing."

  Scenario: Downloading published package does not require log in
    Given I have facility "ROS Weather Station" with code "ROS_WS"
    And I have experiments
      | name              | facility            |
      | My Experiment     | ROS Weather Station |
    And I add "sample1.txt" to the cart
    And I add "sample2.txt" to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Filename" with "my_package"
    And I select "My Experiment" from "Experiment"
    And I press "Save"
    Then I should see "Package was successfully created."
    And I follow "Publish"
    Then I should see "Package has been successfully submitted for publishing."
    And I follow "Sign out"
    And I am on the data file download page for my_package.zip
    And show me the page
    Then I should get a file with name "my_package.zip" and content type "application/octet-stream"
    And I should receive a zip file matching "my_package/zip"


# Scenario: Package a selection of files as a BagIt Zip
#   When I add "sample1.txt" to the cart
#   And I add "sample2.txt" to the cart
#   And I click on "Package"
#   Then I should receive a zip file matching "samples/bagit"

# this functionality has been disabled for now - leaving here in case we re-instate it
#  Scenario: Download a single file from the view data file details page
#    When I am on the data file details page for sample1.txt
#    When I click on "Download Data"
#    Then I should get a file with name "sample1.txt" and content type "text/plain"
#    And the file should contain "Plain text file sample1.txt"
