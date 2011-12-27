Feature: Search data files by date range
  In order to find what I need
  As a user
  I want to search for files with data in a given date range

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have data files
      | filename      | created_at       | uploaded_by               | start_time            | end_time               |
      | datafile8.dat | 08/11/2011 10:15 | georgina@intersect.org.au | 1/5/2010 6:42:01 UTC  | 30/5/2010 18:05:23 UTC |
      | datafile7.dat | 30/11/2011 10:15 | georgina@intersect.org.au | 1/6/2010 6:42:01 UTC  | 10/6/2010 18:05:23 UTC |
      | datafile6.dat | 30/12/2011 10:15 | kali@intersect.org.au     | 1/6/2010 6:42:01 UTC  | 11/6/2010 18:05:23 UTC |
      | datafile5.dat | 30/11/2011 19:00 | matthew@intersect.org.au  | 1/6/2010 6:42:01 UTC  | 12/6/2010 18:05:23 UTC |
      | datafile4.dat | 1/11/2011 10:15  | marc@intersect.org.au     | 10/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC |
      | datafile3.dat | 30/1/2010 10:15  | sean@intersect.org.au     | 11/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC |
      | datafile2.dat | 30/11/2011 8:45  | kali@intersect.org.au     | 12/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC |
      | datafile1.dat | 01/12/2011 13:45 | sean@intersect.org.au     |                       |                        |

  Scenario: Search for files by date range - from date only
    When I do a date search for data files with dates "2010-06-11" and ""
    Then I should see "exploredata" table with
      | Filename      | Date added       | Added by                 | Start time          | End time            |
      | datafile6.dat | 2011-12-30 10:15 | kali@intersect.org.au    | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | matthew@intersect.org.au | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | datafile2.dat | 2011-11-30  8:45 | kali@intersect.org.au    | 2010-06-12  6:42:01 | 2010-06-30 18:05:23 |
      | datafile4.dat | 2011-11-01 10:15 | marc@intersect.org.au    | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
      | datafile3.dat | 2010-01-30 10:15 | sean@intersect.org.au    | 2010-06-11  6:42:01 | 2010-06-30 18:05:23 |
    And I should see "Showing files containing data for 2010-06-11 onwards"
    And the "from_date" field should contain "2010-06-11"
    And the "to_date" field should contain ""

  Scenario: Search for files by date range - to date only
    When I do a date search for data files with dates "" and "2010-06-10"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Added by                  | Start time          | End time            |
      | datafile6.dat | 2011-12-30 10:15 | kali@intersect.org.au     | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | matthew@intersect.org.au  | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | datafile7.dat | 2011-11-30 10:15 | georgina@intersect.org.au | 2010-06-01  6:42:01 | 2010-06-10 18:05:23 |
      | datafile8.dat | 2011-11-08 10:15 | georgina@intersect.org.au | 2010-05-01  6:42:01 | 2010-05-30 18:05:23 |
      | datafile4.dat | 2011-11-01 10:15 | marc@intersect.org.au     | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
    And I should see "Showing files containing data up to 2010-06-10"
    And the "from_date" field should contain ""
    And the "to_date" field should contain "2010-06-10"

  Scenario: Search for files by date range - from and to date
    When I do a date search for data files with dates "2010-06-03" and "2010-06-10"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Added by                  | Start time          | End time            |
      | datafile6.dat | 2011-12-30 10:15 | kali@intersect.org.au     | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | matthew@intersect.org.au  | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | datafile7.dat | 2011-11-30 10:15 | georgina@intersect.org.au | 2010-06-01  6:42:01 | 2010-06-10 18:05:23 |
      | datafile4.dat | 2011-11-01 10:15 | marc@intersect.org.au     | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
    And I should see "Showing files containing data in the range 2010-06-03 to 2010-06-10"
    And the "from_date" field should contain "2010-06-03"
    And the "to_date" field should contain "2010-06-10"

  Scenario: Should be able to sort within search results
    When I do a date search for data files with dates "2010-06-03" and "2010-06-10"
    And I follow "Filename"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Added by                  | Start time          | End time            |
      | datafile4.dat | 2011-11-01 10:15 | marc@intersect.org.au     | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | matthew@intersect.org.au  | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | datafile6.dat | 2011-12-30 10:15 | kali@intersect.org.au     | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile7.dat | 2011-11-30 10:15 | georgina@intersect.org.au | 2010-06-01  6:42:01 | 2010-06-10 18:05:23 |

  Scenario: Go back to showing all after searching
    When I do a date search for data files with dates "2010-06-03" and "2010-06-10"
    Then the "exploredata" table should have 4 rows
    When I follow "Show all files"
    Then the "exploredata" table should have 8 rows

  Scenario: Entering no date shows all
    When I do a date search for data files with date ""
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
    Then I should see "No files to display."
    Then the "from_date" field should contain "2012-06-12"
    And the "to_date" field should contain "2012-06-13"
