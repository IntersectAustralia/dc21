Feature: Perform searching via API
  As a researcher
  I want to perform a search via API so I can run this search from scripts to analyse data.

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And user "researcher@intersect.org.au" has an API token
    And I have data files
      | filename     | created_at       | uploaded_by               | file_processing_status | experiment  |
      | sample1.txt  | 01/12/2011 13:45 | sean@intersect.org.au     | RAW                    | Experiment4 |
      | sample2.txt  | 01/12/2011 12:45 | kali@intersect.org.au     | CLEANSED               | Experiment2 |
      | sample3.txt  | 01/12/2011 11:45 | georgina@intersect.org.au | RAW                    | Experiment5 |
      | sample4.txt  | 01/12/2011 10:45 | matthew@intersect.org.au  | CLEANSED               | Experiment1 |
      | sample5.txt  | 01/12/2011 09:45 | admin@intersect.org.au    | RAW                    | Experiment3 |

  Scenario: Search via API
    When I perform an API search with the following parameters as user "researcher@intersect.org.au"
      | stati | RAW |
    Then I should get a 200 response code
    And I should get a JSON response with
      | filename     |
      | sample1.txt  |
      | sample3.txt  |
      | sample5.txt  |
    And I should have file download link for each entry
