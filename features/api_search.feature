Feature: Perform searching via API
  As a researcher
  I want to perform a search via API so I can run this search from scripts to analyse data.

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Institutional User"
    And user "researcher@intersect.org.au" has an API token
    Given I have a user "tao@intersect.org.au" with role "Admin User"
    And user "tao@intersect.org.au" has an API token
    Given I have a user "test@intersect.org.au" with role "Researcher"
    And user "test@intersect.org.au" has an API token
    And I have tags
      | name  |
      | Photo |
      | Video |
      | Audio |
    And I have data files
      | filename    | created_at       | uploaded_by               | file_processing_status | file_processing_description | experiment  | id | external_id | tags         | label_list | facility | transfer_status | access_rights_type | grant_numbers | related_websites     | contributors | creator |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | RAW                    | ends with a                 | Experiment4 | 4  | sean        | Photo, Video | sean       | fac10    | COMPLETE        | Open               | 1             | http://www.google.com       |   cont1    |test@intersect.org.au|
      | sample2.txt | 01/12/2011 12:45 | kali@intersect.org.au     | CLEANSED               | ends with A                 | Experiment2 | 2  | kali        | Photo        | kali       | fac10    | FAILED          | Open               | 2             | http://www.intersect.org.au |   cont2    |                     |
      | sample3.txt | 01/12/2011 11:45 | georgina@intersect.org.au | RAW                    | nothing common              | Experiment5 | 5  | georgina    | Video        | georgina   | fac20    | WORKING         | Open               | 3             | http://www.sydney.edu.au    |   cont3    |                     |
      | sample4.txt | 01/12/2011 10:45 | matthew@intersect.org.au  | CLEANSED               | starts with                 | Experiment1 | 1  | matthew     | Audio        | matthew    | fac20    | QUEUED          | Restricted         | 4             | http://www.uts.edu.au       |   cont4    | tao@intersect.org.au|
      | sample5.txt | 01/12/2011 09:45 | admin@intersect.org.au    | RAW                    | no description              | Experiment3 | 3  | admin       |              | admin      | fac30    | WORKING         | Conditional        | 5             | http://www.unsw.edu.au      |   cont5    |                     |

  Scenario: Try to search without an API token
    When I perform an API search without an API token
      | stati | RAW |
    Then I should get a 401 response code

  Scenario: Try to search with an invalid API token
    When I perform an API search with an invalid API token
      | stati | RAW |
    Then I should get a 401 response code

  Scenario: Search via API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | stati | RAW |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample1.txt |
      | sample3.txt |
      | sample5.txt |
    And I should have file download link for each entry

  Scenario: Search by experiment via API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | experiments | Experiment4, Experiment1 |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample1.txt |
      | sample4.txt |
    And I should have file download link for each entry

  Scenario: Search by facility via API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | facilities | fac10, fac30 |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample1.txt |
      | sample2.txt |
      | sample5.txt |
    And I should have file download link for each entry

  Scenario: Search by description regex via API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | description | with.*$ |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample1.txt |
      | sample2.txt |
      | sample4.txt |
    And I should have file download link for each entry
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | description | with$ |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample4.txt |
    And I should have file download link for each entry
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | description | a$ |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample1.txt |
      | sample2.txt |
    And I should have file download link for each entry
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | description | ^[es] |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample1.txt |
      | sample2.txt |
      | sample4.txt |
    And I should have file download link for each entry

  Scenario: Search by ID via API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | id | a.*n$ |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample1.txt |
      | sample5.txt |
    And I should have file download link for each entry

  Scenario: Search by File ID via API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | file_id | 1 |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample4.txt |
    And I should have file download link for each entry

  Scenario: Search by Tags via API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | tags | Photo, Audio |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample1.txt |
      | sample2.txt |
      | sample4.txt |
    And I should have file download link for each entry

#EYETRACKER-91

  Scenario: Search by Labels via API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | labels | sean, admin |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample1.txt |
      | sample5.txt |
    And I should have file download link for each entry

    #UWSHIEVMOD-132
  Scenario: Search by Contributors via the API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | contributors | cont1, cont3 |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample1.txt |
      | sample3.txt |
    And I should have file download link for each entry

  Scenario: Search by Creators via the API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | creators | tao@intersect.org.au, test@intersect.org.au, admin@intersect.org.au |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample1.txt |
      | sample4.txt |
      | sample5.txt |
    And I should have file download link for each entry

  Scenario: Prevent searching a not approved Creator
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | creators | tao@intersect.org.au, hahaha@intersect.org.au, admin@intersect.org.au |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample4.txt |
      | sample5.txt |
    And I should have file download link for each entry
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | creators | hahaha@intersect.org.au |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |


#EYETRACKER-135

  Scenario: Search by Automation Stati via API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | automation_stati | FAILED, QUEUED |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample2.txt |
      | sample4.txt |
    And I should have file download link for each entry

  Scenario: Search by Access Rights Type via the API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | access_rights_types | Restricted, Conditional |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample4.txt |
      | sample5.txt |
    And I should have file download link for each entry

  Scenario: Search by Grant Numbers via the API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | grant_numbers | 2, 4 |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample2.txt |
      | sample4.txt |
    And I should have file download link for each entry

  Scenario: Search by Related Websites via the API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | related_websites | http://www.uts.edu.au, http://www.sydney.edu.au |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | sample3.txt |
      | sample4.txt |
    And I should have file download link for each entry

  Scenario: Search via API with some restricted data files that the user does not have access to
    Given I have a user "external@intersect.org.au" with role "Non-Institutional User"
    And user "external@intersect.org.au" has an API token
    And I have access groups
      | name    | users                     | id |
      | group-1 | external@intersect.org.au | 1  |
      | group-2 |                           | 2  |
    And I have data files
      | filename    | uploaded_by                 | file_processing_status | experiment  | access  | access_to_all_institutional_users | access_to_user_groups | access_group_ids | format | created_at | file_size | file_processing_description |
      | 1.dat       | researcher@intersect.org.au | My type                | Experiment1 | Private | true                              | true                  | 1                | text     | 21/03/2014 14:46 | 100  | description 1      |
      | 2.dat       | researcher@intersect.org.au | My type                | Experiment1 | Private | true                              | true                  | 2                | text     | 21/03/2014 14:46 | 200 | description 2      |
      | 3.dat       | external@intersect.org.au   | My type                | Experiment2 | Private | false                             | true                  |                  | text     | 21/03/2014 14:46 | 300 | description 3      |
      | toa5.dat    | researcher@intersect.org.au | My type                | Experiment4 | Public  |                                   |                       |                  | TOA5     | 21/03/2014 14:46 | 400 | description 4      |
    When I perform an API search with the following parameters as user "external@intersect.org.au"
      | stati | My type |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    | format | published | file_processing_description | created_at                | file_size | file_processing_status |
      | 1.dat       | text   | false     | description 1               | 2014-03-21T14:46:00+11:00 | 100.0     | My type                |
      | 2.dat       |        |           |                             | 2014-03-21T14:46:00+11:00 | 200.0     | My type                |
      | 3.dat       | text   | false     | description 3               | 2014-03-21T14:46:00+11:00 | 300.0     | My type                |
      | toa5.dat    | TOA5   | false     | description 4               | 2014-03-21T14:46:00+11:00 | 400.0     | My type                |
