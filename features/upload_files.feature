Feature: Upload files
  In order to manage my data
  As a user
  I want to upload a file

  Background:
    Given I am logged in as "georgina@intersect.org.au"

  Scenario: Upload a single file
    Given I am on the upload page
    When I upload "sample1.txt" through the applet
    When I follow "Done"
    Then I should be on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Added by                  | Start time | End time |
      | sample1.txt | georgina@intersect.org.au |            |          |

    
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
