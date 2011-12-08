Feature: Download a file
  In order to make use of the data
  As a user
  I want to download a data file

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I upload "sample.txt" through the applet

  Scenario: Download
    When I am on the data file details page for sample.txt
    When I follow "Download"
    Then I should get a file with name "sample.txt" and content type "text/plain"
    And the file should contain "This file just contains some text"
