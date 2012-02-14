Feature: Upload files
  In order to manage my data
  As a user
  I want to upload a file

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the upload page
    When I upload "sample1.txt" through the applet


  Scenario: Upload a single file and ignore post processing
    Given I follow "Next"
    And I am on the set data file status page
    When I press "Done"
    Then I should be on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Added by                  | Start time | End time | Processing Status |
      | sample1.txt | georgina@intersect.org.au |            |          | UNDEFINED         |
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Processing Status | UNDEFINED |

  Scenario: Assign a status and description to a newly uploaded file
    Given I follow "Next"
    And I am on the set data file status page
    When I select "RAW" from the select box for "sample1.txt"
    And I fill in "file_processing_description" with "Raw sample file" for "sample1.txt"
    And I press "Done"
    Then I should be on the list data files page
    And I should see "exploredata" table with
      | Filename    | Added by                  | Start time | End time | Processing Status |
      | sample1.txt | georgina@intersect.org.au |            |          | RAW               |
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Processing Status      | RAW             |
      | Processing Description | Raw sample file |

  Scenario: Assign a status and description to only one of two newly uploaded files
    Given I upload "sample2.txt" through the applet
    Given I follow "Next"
    And I am on the set data file status page
    When I select "RAW" from the select box for "sample1.txt"
    And I fill in "file_processing_description" with "Raw sample file" for "sample1.txt"
    And I press "Done"
    Then I should be on the list data files page
    And I should see "exploredata" table with
      | Filename    | Added by                  | Start time | End time | Processing Status |
      | sample2.txt | georgina@intersect.org.au |            |          | UNDEFINED         |
      | sample1.txt | georgina@intersect.org.au |            |          | RAW               |
    And I follow the view link for data file "sample1.txt"
    Then I should see details displayed
      | Processing Status      | RAW             |
      | Processing Description | Raw sample file |
    And I follow "Explore Data"
    And I follow the view link for data file "sample2.txt"
    Then I should see details displayed
      | Processing Status | UNDEFINED |
    And I should not see "Processing Description"

  @wip
  Scenario: Assign a status and description to multiple existing uploaded files
    When I press "Done"
    Then I should be on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Added by                  | Start time | End time | Processing Status | Description |
      | sample1.txt | georgina@intersect.org.au |            |          |                   |             |


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
