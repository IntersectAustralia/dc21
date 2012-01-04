@javascript
Feature: Download a file
  In order to make use of the data
  As a user
  I want to download a data file

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I upload "sample1.txt" through the applet
    And I upload "weather_station_05_min.dat" through the applet
    And I upload "weather_station_15_min.dat" through the applet
    And I upload "WTC01_Table1.dat" through the applet

  Scenario: Build a custom download by date
    When I am on the list data files page
    And I do a date search for data files with dates "2011-10-10" and "2011-10-15"
    And I follow "Download Files"
    And I check the checkbox for "weather_station_05_min.dat"
    And I check the checkbox for "weather_station_15_min.dat"
    And I press "Build Custom Download"
    Then I should see "Include all data"
    And I should see "Only include data in the following range"
    And the "From Date:" field should contain "2011-10-10"
    And the "To Date:" field should contain "2011-10-15"
    When I choose "Only include data in the following range"
    And I press "Download"
#    Then I should receive a zip file matching "samples/subsetted/range_oct_10_oct_15"

# TODO: start date only
# TODO: end date only
# TODO: Coming from full list without searching -> dates empty, needs to do something with files that don't have dates
# TODO: show the file names somewhere
# TODO: coming from search but changing dates
# TODO: Invalid, missing dates
# TODO: Dates that produce no results
