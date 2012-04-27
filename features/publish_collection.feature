Feature: Publish a collection
  In order to tell ANDS about my data
  As a user
  I want to publish a collection

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have experiments
      | name            | subject  | access_rights                                       |
      | Rain Experiment | Rainfall | http://creativecommons.org/licenses/by-nc-nd/3.0/au |
      | Tree Experiment | Trees    | http://creativecommons.org/licenses/by-nc-sa/3.0/au |
    And experiment "Rain Experiment" has for code "0202 - ITEM 2" with url "http://purl.org/asc/1297.0/2008/for/0202"
    And experiment "Rain Experiment" has for code "030304 - ITEM 4" with url "http://purl.org/asc/1297.0/2008/for/030304"
    And experiment "Tree Experiment" has for code "05 - ENVIRONMENTAL SCIENCES" with url "http://purl.org/asc/1297.0/2008/for/05"
    And I have uploaded "sample1.txt" with type "RAW" and description "sample1 desc" and experiment "Rain Experiment"
    And I have uploaded "weather_station_05_min.dat" with type "PROCESSED" and description "5 min desc" and experiment "Rain Experiment"
    And I have uploaded "weather_station_15_min.dat" with type "RAW" and description "15 min desc" and experiment "Rain Experiment"
    And I have uploaded "WTC01_Table1.dat" with type "PROCESSED" and description "wtc01 desc" and experiment "Tree Experiment"
    And I have uploaded "sample2.txt" with type "PROCESSED" and description "sample 2" and experiment "Tree Experiment"
    And I have set the dates of "sample2.txt" as "2011-10-12" to "2011-11-12"

  @javascript
  Scenario: Search by date range then publish - zip should include subsetted files (where its possible to subset) and originals (where we can't subset)
    Given I do a date search for data files with dates "2011-10-10" and "2011-10-15"
    And I publish these search results as "My Collection Of Stuff" with description "Describe my collection of stuff"
    Then there should be a published collection record named "My Collection Of Stuff" with creator "georgina@intersect.org.au"
    And the RIF-CS file for the latest published collection should match "samples/rif-cs/range_oct_10_oct_15.xml"
    When I perform a GET for the zip file for the latest published collection I should get a zip matching "samples/published_zips/range_oct_10_oct_15"

  @javascript
  Scenario: Search by something other than date then publish - zip should include full files
    Given I am on the list data files page
    And I click on "Type:"
    And I check "RAW"
    And I press "Update Search Results"
    And I publish these search results as "Raw Stuff" with description ""
    Then there should be a published collection record named "Raw Stuff" with creator "georgina@intersect.org.au"
    And the RIF-CS file for the latest published collection should match "samples/rif-cs/type_raw_search.xml"
    When I perform a GET for the zip file for the latest published collection I should get a zip matching "samples/published_zips/type_raw"

  Scenario: Publish button does not show if no results from the search
    Given I am on the list data files page
    And I click on "Type:"
    And I check "CLEANSED"
    And I press "Update Search Results"
    Then I should see "No matching files"
    And I should not see link "Publish"

  Scenario: Publish button does not show prior to searching
    Given I am on the list data files page
    Then I should not see link "Publish"

  @javascript
  Scenario: Try to publish without entering a name
    Given I do a date search for data files with dates "2011-10-10" and "2011-10-15"
    When I follow "Publish"
    Then I should be on the publish page
    When I press "Confirm"
    And I should see "Name can't be blank"
    And there should be no published collections

  @javascript
  Scenario: Try to publish with a duplicate name
    Given I have a published collection called "my collection"
    And I do a date search for data files with dates "2011-10-10" and "2011-10-15"
    When I follow "Publish"
    And I fill in "Name" with "my collection"
    And I press "Confirm"
    Then I should see "Name has already been taken"

  Scenario: RIF-CS and zip file are snapshots at the point in time where the collection was published
    Given pending
# TODO: publish a collection, then change some metadata / add more files, check that RIFCS and zip doesn't change


