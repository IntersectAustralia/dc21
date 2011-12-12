Feature: Viewing metadata from toa5 files
  In order to understand the data
  As a user
  I want to see information about toa5 files

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I upload "toa5.dat" through the applet

  Scenario: View on list page
    When I am on the list data files page
    Then I should see "exploredata" table with
      | Name     | Added by | Start time          | End time            |
      | toa5.dat |          | 2011-10-06  0:40:00 | 2011-11-03 11:55:00 |

  Scenario: View details
    When I am on the data file details page for toa5.dat
    Then I should see details displayed
      | Name             | toa5.dat                      |
      | Added by         |                               |
      | Start time       | 2011-10-06  0:40:00           |
      | End time         | 2011-11-03 11:55:00           |
      | File format      | TOA5                          |
      | Datalogger model | CR3000                        |
      | Station name     | ROS_WS                        |
      | Serial number    | 4909                          |
      | Os version       | CR3000.Std.11                 |
      | Dld name         | CPU:weather_station_final.CR3 |
      | Dld signature    | 30238                         |
      | Table name       | Table05min                    |
