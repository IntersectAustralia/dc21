Feature: Upload files
  In order to manage my data
  As a user
  I want to upload a file

  Background:
    Given I am logged in as "georgina@intersect.org.au"

  Scenario: Upload a single file
    Given I am on the upload page
    When I upload "sample1.txt" through the applet
    When I am on the list data files page
    Then I should see "exploredata" table with
      | Name        | Added by | Start time | End time |
      | sample1.txt |          |            |          |

  Scenario: Must be logged in to view the upload page
    Then users should be required to login on the upload page

  Scenario: Must be logged in to upload
#TODO
