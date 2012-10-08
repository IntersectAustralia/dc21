Feature: Search data files by date range
  In order to find what I need
  As a user
  I want to search for files by a variety of criteria

  Background:
    Given I have users
      | email                  | first_name | last_name |
      | one@intersect.org.au   | First      | One       |
      | two@intersect.org.au   | Second     | Two       |
      | three@intersect.org.au | Third      | Three     |
      | four@intersect.org.au  | Fourth     | Four      |
      | five@intersect.org.au  | Fifth      | Five      |
    And I am logged in as "admin@intersect.org.au"
    And I have tags
      | name  |
      | Photo |
      | Video |
      | Audio |
    And I have data files
      | filename      | created_at       | uploaded_by            | start_time            | end_time               | file_processing_status | file_processing_description | tags         | experiment    |
      | mydata8.dat   | 08/11/2011 10:15 | one@intersect.org.au   | 1/5/2010 6:42:01 UTC  | 30/5/2010 18:05:23 UTC | RAW                    | words words words           | Photo, Video | My Experiment |
      | mydata7.dat   | 30/11/2011 10:15 | one@intersect.org.au   | 1/6/2010 6:42:01 UTC  | 10/6/2010 18:05:23 UTC | PROCESSED              | blah                        |              | My Experiment |
      | mydata6.dat   | 30/12/2011 10:15 | two@intersect.org.au   | 1/6/2010 6:42:01 UTC  | 11/6/2010 18:05:23 UTC | CLEANSED               | theword                     | Photo        | My Experiment |
      | datafile5.dat | 30/11/2011 19:00 | three@intersect.org.au | 1/6/2010 6:42:01 UTC  | 12/6/2010 18:05:23 UTC | RAW                    | asdf                        | Video        | My Experiment |
      | datafile4.dat | 1/11/2011 10:15  | four@intersect.org.au  | 10/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC | CLEANSED               |                             | Audio        | Other         |
      | datafile3.dat | 30/1/2010 10:15  | five@intersect.org.au  | 11/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC | ERROR                  |                             |              | Experiment 2  |
      | datafile2.dat | 30/11/2011 8:45  | two@intersect.org.au   | 12/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC | RAW                    | myword                      | Video        | My Experiment |
      | datafile1.dat | 01/12/2011 13:45 | five@intersect.org.au  |                       |                        | UNKNOWN                |                             |              | Experiment 2  |
    And file "mydata8.dat" has metadata item "station_name" with value "ROS_WS"
    And file "mydata7.dat" has metadata item "station_name" with value "TC"
    And file "mydata6.dat" has metadata item "station_name" with value "HFE_WS"
    And file "datafile5.dat" has metadata item "station_name" with value "TC"
    And file "datafile4.dat" has metadata item "station_name" with value "HFE_WS"
    And file "mydata8.dat" has column info "Rnfll", "Millilitres", "Tot"
    And file "mydata6.dat" has column info "Rnfll", "Millilitres", "Tot"
    And file "mydata6.dat" has column info "Temp", "DegC", "Avg"
    And file "datafile5.dat" has column info "Rnfl", "Millilitres", "Tot"
    And file "datafile4.dat" has column info "Humi", "Percent", "Avg"
    And file "datafile1.dat" has column info "Temp_2", "DegC", "Avg"
    And file "datafile1.dat" has column info "humidity", "DegC", "Avg"
    And I have facilities
      | name                | code   |
      | HFE Weather Station | HFE_WS |
      | Tree Chambers       | TC     |
    And I have column mappings
      | code   | name        |
      | Rnfll  | Rainfall    |
      | Rnfl   | Rainfall    |
      | Temp   | Temperature |
      | temp2  | Temperature |
      | Temp_2 | Temperature |


  Scenario: Search for files by date range - from date only
    When I do a date search for data files with dates "2010-06-11" and ""
    Then I should see "exploredata" table with
      | Filename      | Date added       | Experiment    |
      | mydata6.dat   | 2011-12-30 10:15 | My Experiment |
      | datafile5.dat | 2011-11-30 19:00 | My Experiment |
      | datafile2.dat | 2011-11-30  8:45 | My Experiment |
      | datafile4.dat | 2011-11-01 10:15 | Other         |
      | datafile3.dat | 2010-01-30 10:15 | Experiment 2  |
    And the "from_date" field should contain "2010-06-11"
    And the "to_date" field should contain ""
    And I should see "Showing 5 matching files"

  Scenario: Search for files by date range - to date only
    When I do a date search for data files with dates "" and "2010-06-10"
    Then I should see "exploredata" table with
      | Filename      |
      | mydata6.dat   |
      | datafile5.dat |
      | mydata7.dat   |
      | mydata8.dat   |
      | datafile4.dat |
    And the "from_date" field should contain ""
    And the "to_date" field should contain "2010-06-10"

  Scenario: Search for files by date range - from and to date
    When I do a date search for data files with dates "2010-06-03" and "2010-06-10"
    Then I should see "exploredata" table with
      | Filename      |
      | mydata6.dat   |
      | datafile5.dat |
      | mydata7.dat   |
      | datafile4.dat |
    And the "from_date" field should contain "2010-06-03"
    And the "to_date" field should contain "2010-06-10"


  Scenario: Search for files by upload date - from date only
    When I do a date search for data files with upload dates "2011-01-01" and ""
    Then I should see "exploredata" table with
      | Filename      |
      | mydata6.dat   |
      | datafile1.dat |
      | datafile5.dat |
      | mydata7.dat   |
      | datafile2.dat |
      | mydata8.dat   |
      | datafile4.dat |
    And the "upload_from_date" field should contain "2011-01-01"

  Scenario: Search for files by upload date - to date only
    When I do a date search for data files with upload dates "" and "2010-12-31"
    Then I should see "exploredata" table with
      | Filename      |
      | datafile3.dat |
    And the "upload_to_date" field should contain "2010-12-31"

  Scenario: Search for files by upload date - range
    When I do a date search for data files with upload dates "2011-01-01" and "2011-11-30"
    Then I should see "exploredata" table with
      | Filename      |
      | datafile5.dat |
      | mydata7.dat   |
      | datafile2.dat |
      | mydata8.dat   |
      | datafile4.dat |
    And the "upload_from_date" field should contain "2011-01-01"
    And the "upload_to_date" field should contain "2011-11-30"

  @wip
  Scenario: Search for files from specific facilities
    When I am on the list data files page
    Then I should see facility checkboxes
      | HFE Weather Station |
      | ROS_WS              |
      | Tree Chambers       |
    When I check "HFE Weather Station"
    And I check "ROS_WS"
    When I uncheck "Tree Chambers"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      |
      | mydata6.dat   |
      | mydata8.dat   |
      | datafile4.dat |
    And the "ROS_WS" checkbox should be checked
    And the "HFE Weather Station" checkbox should be checked
    And the "Tree Chambers" checkbox should not be checked

    @wip
  Scenario: Search for files from specific facilities and by date range
    When I am on the list data files page
    And I check "HFE Weather Station"
    And I check "ROS_WS"
    And I uncheck "Tree Chambers"
    And I fill in "2010-06-03" for "From Date:"
    And I fill in "2010-06-10" for "To Date:"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      |
      | mydata6.dat   |
      | datafile4.dat |

  Scenario: Search by Uploader
    When I am on the list data files page
    Then the "search_uploader_id" select should contain
      | Please select |
      | Fifth Five    |
      | First One     |
      | Fourth Four   |
      | Fred Bloggs   |
      | Second Two    |
      | Third Three   |        
    And nothing should be selected in the "Uploader:" select
    
    And I select "First One" from "Uploader:"
    And I press "Search"
    Then "First One" should be selected in the "Uploader:" select
    And I should see "exploredata" table with
      | Filename      |
      | mydata7.dat   |
      | mydata8.dat   |



  @javascript
  Scenario: Search for files with certain columns (checking mapped column name)
    When I am on the list data files page
    And I click on "Columns:"
    And I expand all the mapped columns
    Then I should see column checkboxes
      | Rainfall    | Rnfl, Rnfll         |
      | Temperature | Temp, temp2, Temp_2 |
      | Unmapped    | Humi, humidity      |
    When I check "Humi"
    And I check "Rainfall"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      |
      | mydata6.dat   |
      | datafile5.dat |
      | mydata8.dat   |
      | datafile4.dat |
    When I click on "Columns:"
    And I expand all the mapped columns
    Then the "Rainfall" checkbox should be checked
    And the "Humi" checkbox should be checked
    And the "Temp" checkbox should not be checked

  @javascript
  Scenario: Search for files with certain columns (checking raw column names)
    When I am on the list data files page
    And I click on "Columns:"
    And I expand all the mapped columns
    When I check "Humi"
    And I check "Rnfll"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      |
      | mydata6.dat   |
      | mydata8.dat   |
      | datafile4.dat |
    When I click on "Columns:"
    And I expand all the mapped columns
    And the "Humi" checkbox should be checked
    And the "Rnfll" checkbox should be checked
    Then the "Rainfall" checkbox should not be checked
    And the "Rnfl" checkbox should not be checked

  Scenario: Search for files by type
    Given I am on the list data files page
    When I check "RAW"
    And I check "PROCESSED"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      |
      | datafile5.dat |
      | mydata7.dat   |
      | datafile2.dat |
      | mydata8.dat   |
    And the "RAW" checkbox should be checked
    And the "PROCESSED" checkbox should be checked
    And the "CLEANSED" checkbox should not be checked

  Scenario: Search for files by description
    Given I am on the list data files page
    When I fill in "Description" with "word"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      |
      | mydata6.dat   |
      | datafile2.dat |
      | mydata8.dat   |
    And the "Description" field should contain "word"

  Scenario: Search for files by tags
    Given I am on the list data files page
    When I check "Photo"
    And I check "Video"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      |
      | mydata6.dat   |
      | datafile5.dat |
      | datafile2.dat |
      | mydata8.dat   |
    And the "Photo" checkbox should be checked
    And the "Video" checkbox should be checked
    And the "Audio" checkbox should not be checked

  Scenario: Search for files by filename
    Given I am on the list data files page
    When I fill in "Filename" with "my"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename    |
      | mydata6.dat |
      | mydata7.dat |
      | mydata8.dat |
    And the "Filename" field should contain "my"

  @javascript
  Scenario: Search for files by a lot of different things at once
    Given I am on the list data files page
    And I click on "Columns:"
    And I expand all the mapped columns
    And I click on "Filename:"
    And I click on "Tags:"
    And I click on "Description:"
    And I click on "Type:"
    When I fill in "Filename" with "my"
    And I check "Photo"
    And I check "Video"
    And I fill in "Description" with "word"
    And I check "Humi"
    And I check "Rainfall"
    And I check "RAW"
    And I check "PROCESSED"
    And I press "Update Search Results"

  #    And I press "Search"
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by             | Type | Experiment    |
      | mydata8.dat | 2011-11-08 10:15 | one@intersect.org.au | RAW  | My Experiment |
    And I should see "Showing 1 matching file"

  @javascript
  Scenario: Should be able to sort within search results
    Given I am on the list data files page
    When I click on "Date:"
    And I fill in date search details between "2010-06-03" and "2010-06-10"
    And I press "Update Search Results"
    And I follow "Filename"
    Then I should see "exploredata" table with
      | Filename      |
      | datafile4.dat |
      | datafile5.dat |
      | mydata6.dat   |
      | mydata7.dat   |

  Scenario: Go back to showing all after searching
    When I do a date search for data files with dates "2010-06-03" and "2010-06-10"
    Then the "exploredata" table should have 4 rows
    When I follow "Clear Search"
    Then the "exploredata" table should have 8 rows

  Scenario: Entering no date shows all
    When I do a date search for data files with dates "" and ""
    Then the "exploredata" table should have 8 rows

  Scenario: Enter an invalid date
    When I do a date search for data files with dates "asdf" and "2010-06-10"
    Then the "exploredata" table should have 8 rows
    And I should see "You entered an invalid date, please enter dates as yyyy-mm-dd"
    Then the "from_date" field should contain "asdf"
    And the "to_date" field should contain "2010-06-10"

  Scenario: Enter from date that's after to date
    When I do a date search for data files with dates "2010-06-11" and "2010-06-10"
    Then the "exploredata" table should have 8 rows
    And I should see "To date must be on or after from date"
    Then the "from_date" field should contain "2010-06-11"
    And the "to_date" field should contain "2010-06-10"

  Scenario: No results
    When I do a date search for data files with dates "2012-06-12" and "2012-06-13"
    Then I should see "No matching files"
    Then the "from_date" field should contain "2012-06-12"
    And the "to_date" field should contain "2012-06-13"

  @javascript
  Scenario: Checking and unchecking parent column names check/unchecks the children
    Given I am on the list data files page
    And I click on "Columns:"
    And I expand all the mapped columns
    Then I should see column checkboxes
      | Rainfall    | Rnfl, Rnfll         |
      | Temperature | Temp, temp2, Temp_2 |
      | Unmapped    | Humi, humidity      |
    When I check "Rainfall"
    Then the "Rnfll" checkbox should be checked
    And the "Rnfl" checkbox should be checked
    But the "Temp" checkbox should not be checked
    And the "Humi" checkbox should not be checked
    When I uncheck "Rainfall"
    Then the "Rnfll" checkbox should not be checked
    And the "Rnfl" checkbox should not be checked

  @javascript
  Scenario: Unchecking child column name unchecks the parent
    Given I am on the list data files page
    And I click on "Columns:"
    And I expand all the mapped columns
    When I check "Rainfall"
    And I uncheck "Rnfl"
    Then the "Rainfall" checkbox should not be checked

  @javascript
  Scenario: Checking child column name checks the parent if it completes the set
    Given I am on the list data files page
    And I click on "Columns:"
    And I expand all the mapped columns
    When I check "Rnfll"
    Then the "Rainfall" checkbox should not be checked
    When I check "Rnfl"
    Then the "Rainfall" checkbox should be checked

  @javascript @wip

  Scenario: Expanding a parent column name should show the children
    Given I am on the list data files page
    And I click on "Columns:"
    Then I should not see "Rnfl"
    Then I should not see "Rnfll"
    When I expand "Rainfall"
    Then I should see "Rnfl"
    Then I should see "Rnfll"
    When I collapse "Rainfall"
    Then I should not see "Rnfl"
    Then I should not see "Rnfll"

