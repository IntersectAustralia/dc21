Feature: Publish a collection
  In order to tell ANDS about my data
  As a user
  I want to publish a collection

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have uploaded "sample1.txt"
    And I have uploaded "weather_station_05_min.dat"
    And I have uploaded "weather_station_15_min.dat"
    And I have uploaded "WTC01_Table1.dat"

  @javascript
  Scenario: Search by date range then publish
    Given I do a date search for data files with dates "2011-10-10" and "2011-10-15"
    When I follow "Publish"
    Then I should be on the publish page
    When I fill in "Name" with "My Collection Of Stuff"
    And I press "Confirm"
    Then I should be on the home page
    And there should be a published collection record named "My Collection Of Stuff" with creator "georgina@intersect.org.au"
    And I should see "Your collection has been successfully submitted for publishing."
    And the RIF-CS file for the latest published collection should match "samples/rif-cs/range_oct_10_oct_15.xml"
    #When I perform a GET for the zip file for the latest published collection
    #Then I should receive a zip file matching "samples/subsetted/range_oct_10_oct_15"

  Scenario: RIF-CS and zip file are snapshots at the point in time where the collection was published
    # TODO: publish a collection, then change some metadata / add more files, check that RIFCS and zip doesn't change

  Scenario: Build a custom download without searching first (TODO confirm with Stuart)

  Scenario: Publish button does not show if no results from the search

  @javascript
  Scenario: Try to publish without entering a name
    Given I do a date search for data files with dates "2011-10-10" and "2011-10-15"
    When I follow "Publish"
    Then I should be on the publish page
    When I press "Confirm"
    And I should see "Name can't be blank"
    And there should be no published collections

  Scenario: Try to publish with a duplicate name (TODO confirm with Stuart)