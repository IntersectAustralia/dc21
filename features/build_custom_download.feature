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

  Scenario: Build a custom download by date range
    When I do a date search for data files with dates "2011-10-10" and "2011-10-15"
    When I check the checkbox for "weather_station_05_min.dat"
    And I check the checkbox for "weather_station_15_min.dat"
    And I press "Build Custom Download"
    Then I should see the build custom download page with dates populated with "2011-10-10" and "2011-10-15"
    And I should see "weather_station_05_min.dat" within the list of files to download
    And I should see "weather_station_15_min.dat" within the list of files to download
    When I choose "Only include data in the following range"
    And I press "Download"
    Then I should receive a zip file matching "samples/subsetted/range_oct_10_oct_15"

  Scenario: Build a custom download with from date only
    When I do a date search for data files with dates "2011-10-10" and ""
    When I check the checkbox for "weather_station_05_min.dat"
    And I check the checkbox for "weather_station_15_min.dat"
    And I press "Build Custom Download"
    Then I should see the build custom download page with dates populated with "2011-10-10" and ""
    When I choose "Only include data in the following range"
    And I press "Download"
    Then I should receive a zip file matching "samples/subsetted/range_oct_10_onwards"

  Scenario: Build a custom download with to date only
    When I do a date search for data files with dates "" and "2011-10-15"
    When I check the checkbox for "weather_station_05_min.dat"
    And I check the checkbox for "weather_station_15_min.dat"
    And I press "Build Custom Download"
    Then I should see the build custom download page with dates populated with "" and "2011-10-15"
    When I choose "Only include data in the following range"
    And I press "Download"
    Then I should receive a zip file matching "samples/subsetted/range_up_to_oct_15"

  Scenario: Build a custom download without searching first
    When I am on the list data files page
    And I check the checkbox for "weather_station_05_min.dat"
    And I check the checkbox for "WTC01_Table1.dat"
    And I check the checkbox for "sample1.txt"
    And I press "Build Custom Download"
    Then I should see the build custom download page with dates populated with "" and ""
    When I choose "Only include data in the following range"
    And I fill in "From Date:" with "2011-08-01"
    And I fill in "To Date:" with "2011-08-31"
    And I press "Download"
    Then I should receive a zip file matching "samples/subsetted/range_aug_1_aug_31"

  Scenario: Date validation - no dates
    When I am on the list data files page
    And I check the checkbox for "weather_station_05_min.dat"
    And I press "Build Custom Download"
    Then I should see the build custom download page with dates populated with "" and ""
    When I choose "Only include data in the following range"
    And I press "Download"
    Then I should see "Please enter at least one date"

  Scenario: Date validation - invalid date
    When I am on the list data files page
    And I check the checkbox for "weather_station_05_min.dat"
    And I press "Build Custom Download"
    Then I should see the build custom download page with dates populated with "" and ""
    When I choose "Only include data in the following range"
    And I fill in "From Date:" with "asdf"
    And I press "Download"
    Then I should see "You entered an invalid date, please enter dates as yyyy-mm-dd"

  Scenario: Date validation - backwards range
    When I am on the list data files page
    And I check the checkbox for "weather_station_05_min.dat"
    And I press "Build Custom Download"
    Then I should see the build custom download page with dates populated with "" and ""
    When I choose "Only include data in the following range"
    And I fill in "To Date:" with "2011-08-01"
    And I fill in "From Date:" with "2011-08-31"
    And I press "Download"
    Then I should see "To date must be on or after from date"

  Scenario: Try to use dates that will produce no results
    When I am on the list data files page
    And I check the checkbox for "weather_station_05_min.dat"
    And I check the checkbox for "WTC01_Table1.dat"
    And I check the checkbox for "sample1.txt"
    And I press "Build Custom Download"
    Then I should see the build custom download page with dates populated with "" and ""
    When I choose "Only include data in the following range"
    And I fill in "From Date:" with "2012-08-01"
    And I fill in "To Date:" with "2012-08-31"
    And I press "Download"
    Then I should see "There is no data available for the date range you entered."

# TODO: elect to just download all data
# TODO: coming from search but changing dates
