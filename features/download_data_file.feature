Feature: Download a file
  In order to make use of the data
  As a user
  I want to download a data file

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have uploaded "sample1.txt"

  Scenario: Download
    When I am on the data file details page for sample1.txt
    When I click on "Download Data"
    Then I should get a file with name "sample1.txt" and content type "text/plain"
    And the file should contain "Plain text file sample1.txt"
