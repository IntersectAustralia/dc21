Feature: Search data files by date range
  In order to find what I need
  As a user
  I want to search for files by a variety of criteria

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have tags
      | name  |
      | Photo |
      | Video |
      | Audio |
    And I have data files
      | filename      | created_at       | uploaded_by               | start_time            | end_time               | file_processing_status | file_processing_description | tags         |
      | mydata8.dat   | 08/11/2011 10:15 | georgina@intersect.org.au | 1/5/2010 6:42:01 UTC  | 30/5/2010 18:05:23 UTC | RAW                    | words words words           | Photo, Video |
      | mydata7.dat   | 30/11/2011 10:15 | georgina@intersect.org.au | 1/6/2010 6:42:01 UTC  | 10/6/2010 18:05:23 UTC | PROCESSED              | blah                        |              |
      | mydata6.dat   | 30/12/2011 10:15 | kali@intersect.org.au     | 1/6/2010 6:42:01 UTC  | 11/6/2010 18:05:23 UTC | CLEANSED               | theword                     | Photo        |
      | datafile5.dat | 30/11/2011 19:00 | matthew@intersect.org.au  | 1/6/2010 6:42:01 UTC  | 12/6/2010 18:05:23 UTC | RAW                    | asdf                        | Video        |
      | datafile4.dat | 1/11/2011 10:15  | marc@intersect.org.au     | 10/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC | CLEANSED               |                             | Audio        |
      | datafile3.dat | 30/1/2010 10:15  | sean@intersect.org.au     | 11/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC | ERROR                  |                             |              |
      | datafile2.dat | 30/11/2011 8:45  | kali@intersect.org.au     | 12/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC | RAW                    | myword                      | Video        |
      | datafile1.dat | 01/12/2011 13:45 | sean@intersect.org.au     |                       |                        | UNKNOWN                |                             |              |
    And file "mydata8.dat" has metadata item "station_name" with value "ROS_WS"
    And file "mydata7.dat" has metadata item "station_name" with value "TC"
    And file "mydata6.dat" has metadata item "station_name" with value "HFE_WS"
    And file "datafile5.dat" has metadata item "station_name" with value "TC"
    And file "datafile4.dat" has metadata item "station_name" with value "HFE_WS"
    And file "mydata8.dat" has column info "Rnfll", "Millilitres", "Tot"
    And file "mydata6.dat" has column info "Rnfll", "Millilitres", "Tot"
    And file "mydata6.dat" has column info "Temp", "DegC", "Avg"
    And file "datafile5.dat" has column info "Rnfl", "Millilitres", "Tot"
    And file "datafile4.dat" has column info "Humi", "Percemt", "Avg"
    And I have facilities
      | name                | code   |
      | HFE Weather Station | HFE_WS |
      | Tree Chambers       | TC     |
    And I have column mappings
      | code  | name        |
      | Rnfll | Rainfall    |
      | Rnfl  | Rainfall    |
      | Temp  | Temperature |

  Scenario: Search for files by date range - from date only
    When I do a date search for data files with dates "2010-06-11" and ""
    Then I should see "exploredata" table with
      | Filename      | Date added       | Start time          | End time            |
      | mydata6.dat   | 2011-12-30 10:15 | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | datafile2.dat | 2011-11-30  8:45 | 2010-06-12  6:42:01 | 2010-06-30 18:05:23 |
      | datafile4.dat | 2011-11-01 10:15 | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
      | datafile3.dat | 2010-01-30 10:15 | 2010-06-11  6:42:01 | 2010-06-30 18:05:23 |
    And the "from_date" field should contain "2010-06-11"
    And the "to_date" field should contain ""
    And I should see "Showing 5 matching files"

  Scenario: Search for files by date range - to date only
    When I do a date search for data files with dates "" and "2010-06-10"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Start time          | End time            |
      | mydata6.dat   | 2011-12-30 10:15 | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | mydata7.dat   | 2011-11-30 10:15 | 2010-06-01  6:42:01 | 2010-06-10 18:05:23 |
      | mydata8.dat   | 2011-11-08 10:15 | 2010-05-01  6:42:01 | 2010-05-30 18:05:23 |
      | datafile4.dat | 2011-11-01 10:15 | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
    And the "from_date" field should contain ""
    And the "to_date" field should contain "2010-06-10"

  Scenario: Search for files by date range - from and to date
    When I do a date search for data files with dates "2010-06-03" and "2010-06-10"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Start time          | End time            |
      | mydata6.dat   | 2011-12-30 10:15 | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | mydata7.dat   | 2011-11-30 10:15 | 2010-06-01  6:42:01 | 2010-06-10 18:05:23 |
      | datafile4.dat | 2011-11-01 10:15 | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
    And the "from_date" field should contain "2010-06-03"
    And the "to_date" field should contain "2010-06-10"

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
      | Filename      | Date added       | Start time          | End time            |
      | mydata6.dat   | 2011-12-30 10:15 | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | mydata8.dat   | 2011-11-08 10:15 | 2010-05-01  6:42:01 | 2010-05-30 18:05:23 |
      | datafile4.dat | 2011-11-01 10:15 | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
    And the "ROS_WS" checkbox should be checked
    And the "HFE Weather Station" checkbox should be checked
    And the "Tree Chambers" checkbox should not be checked

  Scenario: Search for files from specific facilities and by date range
    When I am on the list data files page
    And I check "HFE Weather Station"
    And I check "ROS_WS"
    And I uncheck "Tree Chambers"
    And I fill in "2010-06-03" for "From Date:"
    And I fill in "2010-06-10" for "To Date:"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Start time          | End time            |
      | mydata6.dat   | 2011-12-30 10:15 | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile4.dat | 2011-11-01 10:15 | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |

  Scenario: Search for files with certain columns
    When I am on the list data files page
    Then I should see variable checkboxes
      | Humi        |
      | Rainfall    |
      | Temperature |
    When I check "Humi"
    And I check "Rainfall"
    When I uncheck "Temperature"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Start time          | End time            |
      | mydata6.dat   | 2011-12-30 10:15 | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | mydata8.dat   | 2011-11-08 10:15 | 2010-05-01  6:42:01 | 2010-05-30 18:05:23 |
      | datafile4.dat | 2011-11-01 10:15 | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
    And the "Rainfall" checkbox should be checked
    And the "Humi" checkbox should be checked
    And the "Temperature" checkbox should not be checked

  Scenario: Search for files by processing status
    Given I am on the list data files page
    When I check "RAW"
    And I check "PROCESSED"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Start time          | End time            |
      | datafile5.dat | 2011-11-30 19:00 | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | mydata7.dat   | 2011-11-30 10:15 | 2010-06-01  6:42:01 | 2010-06-10 18:05:23 |
      | datafile2.dat | 2011-11-30  8:45 | 2010-06-12  6:42:01 | 2010-06-30 18:05:23 |
      | mydata8.dat   | 2011-11-08 10:15 | 2010-05-01  6:42:01 | 2010-05-30 18:05:23 |
    And the "RAW" checkbox should be checked
    And the "PROCESSED" checkbox should be checked
    And the "CLEANSED" checkbox should not be checked

  Scenario: Search for files by description
    Given I am on the list data files page
    When I fill in "Description" with "word"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Start time          | End time            |
      | mydata6.dat   | 2011-12-30 10:15 | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile2.dat | 2011-11-30  8:45 | 2010-06-12  6:42:01 | 2010-06-30 18:05:23 |
      | mydata8.dat   | 2011-11-08 10:15 | 2010-05-01  6:42:01 | 2010-05-30 18:05:23 |
    And the "Description" field should contain "word"

  Scenario: Search for files by tags
    Given I am on the list data files page
    When I check "Photo"
    And I check "Video"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Start time          | End time            |
      | mydata6.dat   | 2011-12-30 10:15 | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | datafile2.dat | 2011-11-30  8:45 | 2010-06-12  6:42:01 | 2010-06-30 18:05:23 |
      | mydata8.dat   | 2011-11-08 10:15 | 2010-05-01  6:42:01 | 2010-05-30 18:05:23 |
    And the "Photo" checkbox should be checked
    And the "Video" checkbox should be checked
    And the "Audio" checkbox should not be checked

  Scenario: Search for files by filename
    Given I am on the list data files page
    When I fill in "Filename" with "my"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename    | Date added       | Start time          | End time            |
      | mydata6.dat | 2011-12-30 10:15 | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | mydata7.dat | 2011-11-30 10:15 | 2010-06-01  6:42:01 | 2010-06-10 18:05:23 |
      | mydata8.dat | 2011-11-08 10:15 | 2010-05-01  6:42:01 | 2010-05-30 18:05:23 |
    And the "Filename" field should contain "my"

  Scenario: Search for files by a lot of different things at once
    Given I am on the list data files page
    When I fill in "Filename" with "my"
    And I check "Photo"
    And I check "Video"
    And I fill in "Description" with "word"
    And I check "Humi"
    And I check "Rainfall"
    And I check "RAW"
    And I check "PROCESSED"
    And I press "Search"
    Then I should see "exploredata" table with
      | Filename    | Date added       | Start time          | End time            |
      | mydata8.dat | 2011-11-08 10:15 | 2010-05-01  6:42:01 | 2010-05-30 18:05:23 |
    And I should see "Showing 1 matching file"

  Scenario: Should be able to sort within search results
    When I do a date search for data files with dates "2010-06-03" and "2010-06-10"
    And I follow "Filename"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Start time          | End time            |
      | datafile4.dat | 2011-11-01 10:15 | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | mydata6.dat   | 2011-12-30 10:15 | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | mydata7.dat   | 2011-11-30 10:15 | 2010-06-01  6:42:01 | 2010-06-10 18:05:23 |

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

