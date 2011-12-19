Feature: Search data files by date range
  In order to find what I need
  As a user
  I want to search for files with data in a given date range

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have data files
      | filename      | created_at       | uploaded_by               | start_time            | end_time               |
      | datafile7.dat | 30/11/2011 10:15 | georgina@intersect.org.au | 1/6/2010 6:42:01 UTC  | 10/6/2010 18:05:23 UTC |
      | datafile6.dat | 30/12/2011 10:15 | kali@intersect.org.au     | 1/6/2010 6:42:01 UTC  | 11/6/2010 18:05:23 UTC |
      | datafile5.dat | 30/11/2011 19:00 | matthew@intersect.org.au  | 1/6/2010 6:42:01 UTC  | 12/6/2010 18:05:23 UTC |
      | datafile4.dat | 1/11/2011 10:15  | marc@intersect.org.au     | 10/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC |
      | datafile3.dat | 30/1/2010 10:15  | sean@intersect.org.au     | 11/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC |
      | datafile2.dat | 30/11/2011 8:45  | kali@intersect.org.au     | 12/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC |
      | datafile1.dat | 01/12/2011 13:45 | sean@intersect.org.au     |                       |                        |

  Scenario: Search for files that include a date
    When I do a date search for data files with date "2010-06-11"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Added by                 | Start time          | End time            |
      | datafile6.dat | 2011-12-30 10:15 | kali@intersect.org.au    | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | matthew@intersect.org.au | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | datafile4.dat | 2011-11-01 10:15 | marc@intersect.org.au    | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
      | datafile3.dat | 2010-01-30 10:15 | sean@intersect.org.au    | 2010-06-11  6:42:01 | 2010-06-30 18:05:23 |
    And I should see "Showing files containing data for 2010-06-11"
    And the "date" field should contain "2010-06-11"

  Scenario: Should be able to sort within search results
    When I do a date search for data files with date "2010-06-11"
    And I follow "Filename"
    Then I should see "exploredata" table with
      | Filename      | Date added       | Added by                 | Start time          | End time            |
      | datafile3.dat | 2010-01-30 10:15 | sean@intersect.org.au    | 2010-06-11  6:42:01 | 2010-06-30 18:05:23 |
      | datafile4.dat | 2011-11-01 10:15 | marc@intersect.org.au    | 2010-06-10  6:42:01 | 2010-06-30 18:05:23 |
      | datafile5.dat | 2011-11-30 19:00 | matthew@intersect.org.au | 2010-06-01  6:42:01 | 2010-06-12 18:05:23 |
      | datafile6.dat | 2011-12-30 10:15 | kali@intersect.org.au    | 2010-06-01  6:42:01 | 2010-06-11 18:05:23 |
    And I should see "Showing files containing data for 2010-06-11"
    And the "date" field should contain "2010-06-11"

  Scenario: Go back to showing all after searching
    When I do a date search for data files with date "2010-06-11"
    Then the "exploredata" table should have 4 rows
    When I follow "Show all files"
    Then the "exploredata" table should have 7 rows

  Scenario: Fail to enter a date
    When I do a date search for data files with date ""
    Then I should see "Please enter a date"

  Scenario: Enter an invalid date
    When I do a date search for data files with date "abcdef"
    Then I should see "The date you entered was invalid. Please enter a valid date"

  Scenario: No results
    When I do a date search for data files with date "2011-10-10"
    Then I should see "No files found for 2011-10-10."
    And the "date" field should contain "2011-10-10"

  Scenario: Must be logged in to search
    Then users should be required to login on the search data files page
