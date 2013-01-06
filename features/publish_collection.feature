@javascript
Feature: Publish a PACKAGE
  In order to tell ANDS about my data
  As a user
  I want to publish a PACKAGE

  Background:
    Given I have the usual roles
    And I have a user "georgina@intersect.org.au" with role "Administrator"
    And I have a user "researcher@intersect.org.au" with role "Researcher"
    And I am logged in as "georgina@intersect.org.au"
    And I have facility "ROS Weather Station" with code "ROS_WS"
    And I have facility "Flux Tower" with code "FLUX"
    And I have data files
      | filename      | file_processing_status | created_at       | uploaded_by                 | start_time       | end_time            | path                  | id | published | published_date      |
      | package1.zip  | PACKAGE                | 01/12/2011 13:45 | researcher@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/package1.zip  | 1  | false     |                     |
      | package2.zip  | PACKAGE                | 30/11/2011 10:15 | georgina@intersect.org.au   | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/package2.zip  | 2  | false     |                     |
      | published.zip | PACKAGE                | 30/12/2011 12:34 | georgina@intersect.org.au   |                  |                     | samples/published.zip | 3  | true      | 27/12/2012 13:05:23 |
      | sample1.txt   | RAW                    | 01/12/2011 13:45 | researcher@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample1.txt   | 4  | false     |                     |
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
#
#  Scenario: Search by date range then publish - zip should include full files (regardless of whether they fall outside date range)
#    Given I do a date search for data files with dates "2011-10-10" and "2011-10-15"
#    And I publish these search results as "My Collection Of Stuff" with description "Describe my collection of stuff"
#    Then there should be a published collection record named "My Collection Of Stuff" with creator "georgina@intersect.org.au"
#    And the RIF-CS file for the latest published collection should match "samples/rif-cs/range_oct_10_oct_15.xml"
#    When I perform a GET for the zip file for the latest published collection I should get a zip matching "samples/published_zips/range_oct_10_oct_15"
#
#  @javascript
#  Scenario: Search by something other than date then publish - zip should include full files
#    Given I am on the list data files page
#    And I click on "Type:"
#    And I check "RAW"
#    And I press "Update Search Results"
#    And I publish these search results as "Raw Stuff" with description ""
#    Then there should be a published collection record named "Raw Stuff" with creator "georgina@intersect.org.au"
#    And the RIF-CS file for the latest published collection should match "samples/rif-cs/type_raw_search.xml"
#    When I perform a GET for the zip file for the latest published collection I should get a zip matching "samples/published_zips/type_raw"
#
#  @javascript
#  Scenario: None of the files have dates - RIFCS should not include temporal coverage
#    Given I am on the list data files page
#    And I click on "Filename:"
#    And I fill in "Filename" with "sample1"
#    And I press "Update Search Results"
#    And I publish these search results as "No Dates" with description ""
#    Then there should be a published collection record named "No Dates" with creator "georgina@intersect.org.au"
#    And the RIF-CS file for the latest published collection should match "samples/rif-cs/sample1-rif-cs.xml"
#

  Scenario: Metadata should reflect publish status for a package
    Given I am on the data file details page for package1.zip
    Then I should see details displayed
      | Name      | package1.zip |
      | Published | No           |
    And I should not see "Published date:"
    When I am on the data file details page for published.zip
    Then I should see details displayed
      | Name           | published.zip    |
      | Published      | Yes              |
      | Published date | 2012-12-27 13:05 |
    When I am on the data file details page for sample1.txt
    Then I should not see "Published:"
    And I should not see "Published date:"

  Scenario: Publish button should only appear for packages
    Given I am on the list data files page
    And I add sample1.txt to the cart
    When I am on the create package page
    And I fill in "Filename" with "my_package"
    And I select "My Experiment" from "Experiment"
    And I press "Save"
    Then I should see "Package was successfully created."
    When I am on the data file details page for sample1.txt
    Then I should not see "Publish"
    When I am on the data file details page for my_package.zip
    Then I should see "Publish"
    And I follow "Publish"
    And I confirm the popup
    And I should see "Package has been successfully submitted for publishing."

  Scenario: Only administrators are allowed to edit a package once published
    Given I logout
    And I am logged in as "researcher@intersect.org.au"
    And I am on the data file details page for published.zip
    Then I should not see "Edit Metadata"
    Then I logout
    When I am logged in as "georgina@intersect.org.au"
    And I am on the data file details page for published.zip


#
#  Scenario: Publish button does not show prior to searching
#    Given I am on the list data files page
#    Then I should not see link "Publish"
#
#  @javascript
#  Scenario: Try to publish without entering a name
#    Given I do a date search for data files with dates "2011-10-10" and "2011-10-15"
#    When I follow "Publish"
#    Then I should be on the publish page
#    When I press "Confirm"
#    And I should see "Name can't be blank"
#    And there should be no published collections
#
#  @javascript
#  Scenario: Try to publish with a duplicate name
#    Given I have a published collection called "my collection"
#    And I do a date search for data files with dates "2011-10-10" and "2011-10-15"
#    When I follow "Publish"
#    And I fill in "Name" with "my collection"
#    And I press "Confirm"
#    Then I should see "Name has already been taken"
#
#  @javascript
#  Scenario: RIF-CS and zip file are snapshots at the point in time where the collection was published
#    # publish
#    Given I do a date search for data files with dates "2011-10-10" and "2011-10-15"
#    And I publish these search results as "My Collection Of Stuff" with description "Describe my collection of stuff"
#    # change some details
#    When I edit data file "weather_station_05_min.dat"
#    And I fill in "Name" with "changedit.dat"
#    And I press "Update"
#    # published collection should remain as before
#    Then there should be a published collection record named "My Collection Of Stuff" with creator "georgina@intersect.org.au"
#    And the RIF-CS file for the latest published collection should match "samples/rif-cs/range_oct_10_oct_15.xml"
#    When I perform a GET for the zip file for the latest published collection I should get a zip matching "samples/published_zips/range_oct_10_oct_15"


