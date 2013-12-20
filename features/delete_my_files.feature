Feature: Delete files containing erroneous data
  In order to maintain the integrity of the data stored in the system
  As a user
  I want to remove my files that are invalid or that I have uploaded erroneously

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    Given I have a user "other_user@intersect.org.au" with role "Researcher"
    Given I have a user "administrator@intersect.org.au" with role "Administrator"

    And I am logged in as "researcher@intersect.org.au"

  @javascript
  Scenario: Cancelling the alert does not delete the file
    And I have uploaded "toa5.dat" as "researcher@intersect.org.au"
    Given I am on the list data files page
    And I should see only these rows in "exploredata" table
      | Filename | Added by                    |
      | toa5.dat | researcher@intersect.org.au |
    And I follow the view link for data file "toa5.dat"
    And I follow "Delete This File"
    And I dismiss the popup
    And I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename | Added by                    |
      | toa5.dat | researcher@intersect.org.au |

  @javascript
  Scenario: I see an informative alert for files with metadata
    Given I have uploaded "toa5.dat" as "researcher@intersect.org.au" with type "RAW"
    When I am on the list data files page
    Then I should see "exploredata" table with
      | Filename | Added by                    | Type |
      | toa5.dat | researcher@intersect.org.au | RAW  |
    When I follow the view link for data file "toa5.dat"
    And I follow "Delete This File"
    Then The popup text should contain "toa5.dat"
    And The popup text should contain "RAW"
    And The popup text should contain "2011-10-06  0:40:00"
    And The popup text should contain "2011-11-03 11:55:00"
    And The popup text should contain "ROS_WS"
    Then I dismiss the popup

  Scenario: Deleting a file removes it from the list of files in Explore Data
    And I have uploaded "toa5.dat" as "researcher@intersect.org.au"
    And I have uploaded "weather_station_15_min.dat" as "researcher@intersect.org.au"
    Given I am on the list data files page
    And I should see only these rows in "exploredata" table
      | Filename                   | Added by                    |
      | weather_station_15_min.dat | researcher@intersect.org.au |
      | toa5.dat                   | researcher@intersect.org.au |
    When I delete the file "weather_station_15_min.dat" added by "researcher@intersect.org.au"
    And I am on the list data files page
    Then I should see only these rows in "exploredata" table
      | Filename | Added by                    |
      | toa5.dat | researcher@intersect.org.au |

  Scenario: Deleting a file causes it to no longer appear in search results
    Given I have data files
      | filename      | created_at       | uploaded_by                 | start_time           | end_time               |
      | datafile7.dat | 30/11/2011 10:15 | researcher@intersect.org.au | 1/6/2010 6:42:01 UTC | 10/6/2010 18:05:23 UTC |
      | datafile6.dat | 30/12/2011 10:15 | other_user@intersect.org.au | 1/6/2010 6:42:01 UTC | 11/6/2010 18:05:23 UTC |
    When I do a date search for data files with dates "2010-06-03" and "2010-06-10"
    Then I should see "exploredata" table with
      | Filename      | Date added       |
      | datafile6.dat | 2011-12-30 10:15 |
      | datafile7.dat | 2011-11-30 10:15 |
    When I delete the file "datafile7.dat" added by "researcher@intersect.org.au"
    And I do a date search for data files with dates "2010-06-03" and "2010-06-10"
    Then I should see "exploredata" table with
      | Filename      | Date added       |
      | datafile6.dat | 2011-12-30 10:15 |

  Scenario: Deleting a file causes it to be removed from any carts it is in
    Given I have data files
      | filename      | created_at       | uploaded_by                 | start_time           | end_time               |
      | datafile7.dat | 30/11/2011 10:15 | researcher@intersect.org.au | 1/6/2010 6:42:01 UTC | 10/6/2010 18:05:23 UTC |
      | datafile6.dat | 30/12/2011 10:15 | other_user@intersect.org.au | 1/6/2010 6:42:01 UTC | 11/6/2010 18:05:23 UTC |
    And the cart for "researcher@intersect.org.au" contains "datafile6.dat"
    And the cart for "researcher@intersect.org.au" contains "datafile7.dat"
    And the cart for "other_user@intersect.org.au" contains "datafile7.dat"
    Then the cart for "other_user@intersect.org.au" should contain 1 file
    And the cart for "researcher@intersect.org.au" should contain 2 files
    And I am on the data file details page for datafile7.dat
    And I follow "Delete This File"
    Then the cart for "other_user@intersect.org.au" should be empty
    And the cart for "researcher@intersect.org.au" should contain 1 file

  Scenario: Files can be deleted from the details page
    Given I have data files
      | filename      | created_at       | uploaded_by                 | start_time           | end_time               |
      | datafile.dat  | 30/11/2011 10:15 | researcher@intersect.org.au | 1/6/2010 6:42:01 UTC | 10/6/2010 18:05:23 UTC |
      | datafile1.dat | 30/11/2011 10:15 | researcher@intersect.org.au | 1/6/2010 6:42:01 UTC | 10/6/2010 18:05:23 UTC |
    And I am on the data file details page for datafile.dat
    And I follow "Delete"
    Then I should be on the list data files page
    And I should see "The file 'datafile.dat' was successfully removed"
    And I should see only these rows in "exploredata" table
      | Filename      | Added by                    |
      | datafile1.dat | researcher@intersect.org.au |

  Scenario: Files with ID can be deleted
    Given I have data files
      | filename     | created_at       | uploaded_by                 | start_time           | end_time               | external_id |
      | datafile.dat | 30/11/2011 10:15 | researcher@intersect.org.au | 1/6/2010 6:42:01 UTC | 10/6/2010 18:05:23 UTC | blah        |
    And I am on the data file details page for datafile.dat
    And I follow "Delete"
    And I should see "The file 'datafile.dat' was successfully removed"

  Scenario: Normal cannot delete others' files because they don't have a link
    And I have data files
      | filename     | created_at       | uploaded_by                 | start_time           | end_time               |
      | datafile.dat | 30/11/2011 10:15 | other_user@intersect.org.au | 1/6/2010 6:42:01 UTC | 10/6/2010 18:05:23 UTC |
    And I am on the data file details page for datafile.dat
    Then I should not see link "Delete"

  Scenario: Normal cannot delete others' files via less scrupulous means
    Given I have data files
      | filename     | created_at       | uploaded_by                 | start_time           | end_time               |
      | datafile.dat | 30/11/2011 10:15 | other_user@intersect.org.au | 1/6/2010 6:42:01 UTC | 10/6/2010 18:05:23 UTC |
    And I visit the delete url for "datafile.dat"
    And I should be on the home page
    And I should see "You are not authorized to access this page."

  Scenario: Super users can delete any file regardless of user
    Given I logout
    And I am logged in as "administrator@intersect.org.au"
    And I have data files
      | filename      | created_at       | uploaded_by                 | start_time           | end_time               |
      | datafile.dat  | 30/11/2011 10:15 | other_user@intersect.org.au | 1/6/2010 6:42:01 UTC | 10/6/2010 18:05:23 UTC |
      | datafile1.dat | 30/11/2011 10:15 | other_user@intersect.org.au | 1/6/2010 6:42:01 UTC | 10/6/2010 18:05:23 UTC |
    And I am on the data file details page for datafile.dat
    And I follow "Delete"
    Then I should be on the list data files page
    And I should see "The file 'datafile.dat' was successfully removed"
    And I should see only these rows in "exploredata" table
      | Filename      | Added by                    |
      | datafile1.dat | other_user@intersect.org.au |
