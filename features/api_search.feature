Feature: Perform searching via API
  As a researcher
  I want to perform a search via API so I can run this search from scripts to analyse data.

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And user "researcher@intersect.org.au" has an API token
    And I have tags
      | name  |
      | Photo |
      | Video |
      | Audio |
    And I have data files
      | filename    | created_at       | uploaded_by               | file_processing_status | file_processing_description | experiment  | id | external_id | tags         | labels   |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | RAW                    | ends with a                 | Experiment4 | 4  | sean        | Photo, Video | sean     |
      | sample2.txt | 01/12/2011 12:45 | kali@intersect.org.au     | CLEANSED               | ends with A                 | Experiment2 | 2  | kali        | Photo        | kali     |
      | sample3.txt | 01/12/2011 11:45 | georgina@intersect.org.au | RAW                    | nothing common              | Experiment5 | 5  | georgina    | Video        | georgina |
      | sample4.txt | 01/12/2011 10:45 | matthew@intersect.org.au  | CLEANSED               | starts with                 | Experiment1 | 1  | matthew     | Audio        | matthew  |
      | sample5.txt | 01/12/2011 09:45 | admin@intersect.org.au    | RAW                    | no description              | Experiment3 | 3  | admin       |              | admin    |

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
