Feature: Perform listing variables via API
  As a researcher
  I want to get a list of all variables via API so I can see what parameters are available for searching

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Institutional User"
    And user "researcher@intersect.org.au" has an API token
    And I have data files
      | filename      | created_at       | uploaded_by            | start_time            | end_time               | file_processing_status | file_processing_description | tags         | label_list | experiment    | facility            | external_id | id | transfer_status | format      | access_rights_type | license                                    | title      |
      | mydata8.dat   | 08/11/2011 10:15 | one@intersect.org.au   | 1/5/2010 6:42:01 UTC  | 30/5/2010 18:05:23 UTC | RAW                    | words words words           | Photo, Video | A, B       | My Experiment | HFE Weather Station | test ID     |    | QUEUED          | TOA5        |                    |                                            |            |
      | mydata7.dat   | 30/11/2011 10:15 | one@intersect.org.au   | 1/6/2010 6:42:01 UTC  | 10/6/2010 18:05:23 UTC | PROCESSED              | blah                        |              | B, C       | My Experiment | HFE Weather Station |             |    | WORKING         | BAGIT       | Conditional        | http://creativecommons.org/licenses/by/4.0 | My Package |
      | mydata6.dat   | 30/12/2011 10:15 | two@intersect.org.au   | 1/6/2010 6:42:01 UTC  | 11/6/2010 18:05:23 UTC | CLEANSED               | theword                     | Photo        | A          | My Experiment | HFE Weather Station |             |    | FAILED          | Unknown     |                    |                                            |            |
      | datafile5.dat | 30/11/2011 19:00 | three@intersect.org.au | 1/6/2010 6:42:01 UTC  | 12/6/2010 18:05:23 UTC | RAW                    | asdf                        | Video        | C          | My Experiment | HFE Weather Station |             |    | COMPLETE        | image/jpeg  |                    |                                            |            |
      | datafile4.dat | 1/11/2011 10:15  | four@intersect.org.au  | 10/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC | CLEANSED               |                             | Audio        | D          | Other         | ROS_WS              |             |    | COMPLETE        | image/png   |                    |                                            |            |
      | datafile3.dat | 30/1/2010 10:15  | five@intersect.org.au  | 11/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC | ERROR                  |                             |              |            | Experiment 2  | Tree Chambers       |             |    | FAILED          | video/mpeg  |                    |                                            |            |
      | datafile2.dat | 30/11/2011 8:45  | two@intersect.org.au   | 12/6/2010 6:42:01 UTC | 30/6/2010 18:05:23 UTC | RAW                    | myword                      | Video        |            | My Experiment | HFE Weather Station |             |    | WORKING         | audio/mpeg  |                    |                                            |            |
      | datafile1.dat | 01/12/2011 13:45 | five@intersect.org.au  |                       |                        | UNKNOWN                |                             |              |            | Experiment 2  | Tree Chambers       |             |    | QUEUED          | audio/x-wav |                    |                                            |            |
    And file "mydata8.dat" has column info "Rnfll", "Millilitres", "Tot"
    And file "mydata6.dat" has extra column info "temp", "DegC", "Avg", "1928.21"
    And file "datafile5.dat" has column info "Rnfl", "Millilitres", "Tot"
    And file "datafile4.dat" has column info "Humi", "Percent", "Avg"
    And file "datafile1.dat" has extra column info "temp3", "DegC", "Avg", "-9922.01"
    And file "datafile1.dat" has column info "humidity", "DegC", "Avg"
    And I have column mappings
      | code  | name        |
      | Rnfll | Rainfall    |
      | Rnfl  | Rainfall    |
      | temp  | Temperature |
      | temp2 | Temperature |
      | temp3 | Temperature |

  Scenario: Try to get variable list without an API token
    When I get the variable list without an API token
    Then I should get a 401 response code

  Scenario: Try to search with an invalid API token
    When I get the variable list with an invalid API token
    Then I should get a 401 response code

  Scenario: Get variable list via API
    When I get the variable list as user "researcher@intersect.org.au"
    Then I should get a 200 response code
    And I should get a JSON response with
      | name        | unit         | data_type | fill_value | mapping           |
      | Rnfll       |  Millilitres |  Tot      |            | Rainfall          |
      | temp        |  DegC        |  Avg      | 1928.21    | Temperature       |
      | Rnfl        |  Millilitres |  Tot      |            | Rainfall          |
      | Humi        |  Percent     |     Avg   |            |                   |
      | temp3       |  DegC        |  Avg      | -9922.01   | Temperature       |
      | humidity    |  DegC        |    Avg    |            |                   |



