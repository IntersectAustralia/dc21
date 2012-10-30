Feature: Download multiple files
  In order to get hold of the data I'm interested in
  As a user
  I want to download multiple files from the explore data page

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have data files
      | filename    | created_at       | uploaded_by               | start_time       | end_time            | path                |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au     | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample1.txt |
      | sample2.txt | 30/11/2011 10:15 | georgina@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample2.txt |
      | sample3.txt | 30/12/2011 12:34 | georgina@intersect.org.au |                  |                     | samples/sample3.txt |
    And I am on the list data files page


  @javascript
  Scenario: Download button doesn't appear until files are selected
    Then I should not see button "Download Selected Files"
    When I check file "sample1.txt"
    Then I should see button "Download Selected Files"
    When I uncheck file "sample1.txt"
    Then I should not see button "Download Selected Files"

  Scenario: Download a selection of files
    When I check file "sample1.txt"
    And I check file "sample2.txt"
    And I press "Download Selected Files"
    Then I should get a file with name "download_selected.zip" and content type "application/zip"

  @javascript
  Scenario: 'All' link checks all files
    When I click on "All"
    Then file "sample1.txt" should be checked
    Then file "sample2.txt" should be checked
    Then file "sample3.txt" should be checked

  @javascript
  Scenario: 'None' link unchecks all files
    When I check file "sample1.txt"
    When I check file "sample3.txt"
    When I click on "None"
    Then file "sample1.txt" should be unchecked
    Then file "sample2.txt" should be unchecked
    Then file "sample3.txt" should be unchecked

