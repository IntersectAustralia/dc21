Feature: Viewing metadata from toa5 files
  In order to understand the data
  As a user
  I want to see information about toa5 files

  Background:
    Given I am logged in as "admin@intersect.org.au"
    And I have uploaded "toa5.dat"

  Scenario: View details
    When I am on the data file details page for toa5.dat
    Then I should see details displayed
      | Name             | toa5.dat                      |
      | Added by         | admin@intersect.org.au        |
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
    And I should see "column_info" table with
      | Column     | Unit          | Measurement Type |
      | TIMESTAMP  | TS            |                  |
      | RECORD     | RN            |                  |
      | PPFD_Avg   | mV            | Avg              |
      | AirTC_Avg  | Deg C         | Avg              |
      | RH         | %             | Smp              |
      | WS_ms_Avg  | meters/second | Avg              |
      | WS_ms_Max  | meters/second | Max              |
      | WindDir    | degrees       | Smp              |
      | NetSW_Avg  | W/m^2         | Avg              |
      | NetLW_Avg  | W/m^2         | Avg              |
      | NetRad_Avg | W/m^2         | Avg              |
      | LWmV_Avg   | mV            | Avg              |
      | LWMDry_Tot | Minutes       | Tot              |
      | LWMCon_Tot | Minutes       | Tot              |
      | LWMWet_Tot | Minutes       | Tot              |
