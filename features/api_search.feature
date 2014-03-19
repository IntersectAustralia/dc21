Feature: Perform searching via API
  As a researcher
  I want to perform a search via API so I can run this search from scripts to analyse data.

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Institutional User"
    And user "researcher@intersect.org.au" has an API token
    And I have tags
      | name  |
      | Photo |
      | Video |
      | Audio |
    And I have data files
      | filename    | created_at       | uploaded_by               | file_processing_status | file_processing_description | experiment  | id | external_id | tags         | label_list | facility | transfer_status |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | RAW                    | ends with a                 | Experiment4 | 4  | sean        | Photo, Video | sean       | fac10    | COMPLETE        |
      | sample2.txt | 01/12/2011 12:45 | kali@intersect.org.au     | CLEANSED               | ends with A                 | Experiment2 | 2  | kali        | Photo        | kali       | fac10    | FAILED          |
      | sample3.txt | 01/12/2011 11:45 | georgina@intersect.org.au | RAW                    | nothing common              | Experiment5 | 5  | georgina    | Video        | georgina   | fac20    | WORKING         |
      | sample4.txt | 01/12/2011 10:45 | matthew@intersect.org.au  | CLEANSED               | starts with                 | Experiment1 | 1  | matthew     | Audio        | matthew    | fac20    | QUEUED          |
      | sample5.txt | 01/12/2011 09:45 | admin@intersect.org.au    | RAW                    | no description              | Experiment3 | 3  | admin       |              | admin      | fac30    | WORKING         |

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

    
  Scenario: Search via API with some restricted data files that the user does not have access to
    Given I have a user "external@intersect.org.au" with role "Non-Institutional User"
    And user "external@intersect.org.au" has an API token
    And I have access groups
      | name    | users                     |
      | group-1 | external@intersect.org.au |
      | group-2 |                           |
    And I have uploaded "1.dat" as "researcher@intersect.org.au" with type "My type" and experiment "Experiment1" and access "Private" with options institutional "true" and user groups "true" and access groups "group-1"
    And I have uploaded "2.dat" as "researcher@intersect.org.au" with type "My type" and experiment "Experiment1" and access "Private" with options institutional "true" and user groups "true" and access groups "group-2"
    When I perform an API search with the following parameters as user "external@intersect.org.au"
      | stati | My type |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename    |
      | 1.dat       |
