Feature: Paginating the list of data files
  In order to display data files
  As a user I want to paginate the data files list as many hundreds of files may be returned

  Background:
    Given We paginate more than 2 data files
    And I am logged in as "admin@intersect.org.au"

  Scenario: No data files
    When I am on the list data files page
    Then I should see "No matching files"
    And I should not see the pagination area

  Scenario: Data files only have one page
    When I have data files
      | filename    | created_at       | uploaded_by           | file_processing_status | experiment  |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au | RAW                    | Experiment4 |
    And I am on the list data files page
    Then I should see "Showing 1 file"
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by              | Type | Experiment  |
      | sample1.txt | 2011-12-01 13:45 | sean@intersect.org.au | RAW  | Experiment4 |
    And I should not see the pagination area

  Scenario: Data files have more than one page
    When I have data files
      | filename    | created_at       | uploaded_by              | file_processing_status | experiment  |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au    | RAW                    | Experiment4 |
      | sample2.txt | 01/12/2011 12:45 | kali@intersect.org.au    | CLEANSED               | Experiment2 |
      | sample3.txt | 01/12/2011 11:45 | admin@intersect.org.au   | RAW                    | Experiment5 |
      | sample4.txt | 01/12/2011 10:45 | matthew@intersect.org.au | CLEANSED               | Experiment1 |
      | sample5.txt | 01/12/2011 09:45 | admin@intersect.org.au   | RAW                    | Experiment3 |
    And I am on the list data files page
    Then I should see "Showing 1-2 of 5 files"
    And I should see "exploredata" table with
      | Filename    | Date added       | Added by              | Type     | Experiment  |
      | sample1.txt | 2011-12-01 13:45 | sean@intersect.org.au | RAW      | Experiment4 |
      | sample2.txt | 2011-12-01 12:45 | kali@intersect.org.au | CLEANSED | Experiment2 |
  #    And I should not see link "Previous" in "the pagination area"
  #    And I should see link "Next" in "the pagination area"
  #    And I should not see link "1" in "the pagination area"
  #    And I should see link "2" in "the pagination area"
  #    And I should see link "3" in "the pagination area"
    When I follow "3" within the pagination area
    Then I should see "Showing 5 of 5 files"
    And I should see "exploredata" table with
      | Filename    | Date added       | Added by               | Type | Experiment  |
      | sample5.txt | 2011-12-01  9:45 | admin@intersect.org.au | RAW  | Experiment3 |
  #    And I should see link "Previous" in "the pagination area"
  #    And I should not see link "Next" in "the pagination area"
  #    And I should see link "1" in "the pagination area"
  #    And I should see link "2" in "the pagination area"
  #    And I should not see link "3" in "the pagination area"
    When I follow "2" within the pagination area
    Then I should see "Showing 3-4 of 5 files"
    And I should see "exploredata" table with
      | Filename    | Date added       | Added by                 | Type     | Experiment  |
      | sample3.txt | 2011-12-01 11:45 | admin@intersect.org.au   | RAW      | Experiment5 |
      | sample4.txt | 2011-12-01 10:45 | matthew@intersect.org.au | CLEANSED | Experiment1 |
#    And I should see link "Previous" in "the pagination area"
#    And I should see link "Next" in "the pagination area"
#    And I should see link "1" in "the pagination area"
#    And I should not see link "2" in "the pagination area"
#    And I should see link "3" in "the pagination area"

  Scenario: View the list, use "next" and "previous" to go to different pages
    When I have data files
      | filename    | created_at       | uploaded_by              | file_processing_status | experiment  |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au    | RAW                    | Experiment4 |
      | sample2.txt | 01/12/2011 12:45 | kali@intersect.org.au    | CLEANSED               | Experiment2 |
      | sample3.txt | 01/12/2011 11:45 | admin@intersect.org.au   | RAW                    | Experiment5 |
      | sample4.txt | 01/12/2011 10:45 | matthew@intersect.org.au | CLEANSED               | Experiment1 |
      | sample5.txt | 01/12/2011 09:45 | admin@intersect.org.au   | RAW                    | Experiment3 |
    And I am on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by              | Type     | Experiment  |
      | sample1.txt | 2011-12-01 13:45 | sean@intersect.org.au | RAW      | Experiment4 |
      | sample2.txt | 2011-12-01 12:45 | kali@intersect.org.au | CLEANSED | Experiment2 |
    When I follow "Next" within the pagination area
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by                 | Type     | Experiment  |
      | sample3.txt | 2011-12-01 11:45 | admin@intersect.org.au   | RAW      | Experiment5 |
      | sample4.txt | 2011-12-01 10:45 | matthew@intersect.org.au | CLEANSED | Experiment1 |
    When I follow "Previous" within the pagination area
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by              | Type     | Experiment  |
      | sample1.txt | 2011-12-01 13:45 | sean@intersect.org.au | RAW      | Experiment4 |
      | sample2.txt | 2011-12-01 12:45 | kali@intersect.org.au | CLEANSED | Experiment2 |

  Scenario: View the list, use page number link to go to different pages
    When I have data files
      | filename    | created_at       | uploaded_by              | file_processing_status | experiment  |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au    | RAW                    | Experiment4 |
      | sample2.txt | 01/12/2011 12:45 | kali@intersect.org.au    | CLEANSED               | Experiment2 |
      | sample3.txt | 01/12/2011 11:45 | admin@intersect.org.au   | RAW                    | Experiment5 |
      | sample4.txt | 01/12/2011 10:45 | matthew@intersect.org.au | CLEANSED               | Experiment1 |
      | sample5.txt | 01/12/2011 09:45 | admin@intersect.org.au   | RAW                    | Experiment3 |
    And I am on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by              | Type     | Experiment  |
      | sample1.txt | 2011-12-01 13:45 | sean@intersect.org.au | RAW      | Experiment4 |
      | sample2.txt | 2011-12-01 12:45 | kali@intersect.org.au | CLEANSED | Experiment2 |
    When I follow "2" within the pagination area
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by                 | Type     | Experiment  |
      | sample3.txt | 2011-12-01 11:45 | admin@intersect.org.au   | RAW      | Experiment5 |
      | sample4.txt | 2011-12-01 10:45 | matthew@intersect.org.au | CLEANSED | Experiment1 |
    When I follow "1" within the pagination area
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by              | Type     | Experiment  |
      | sample1.txt | 2011-12-01 13:45 | sean@intersect.org.au | RAW      | Experiment4 |
      | sample2.txt | 2011-12-01 12:45 | kali@intersect.org.au | CLEANSED | Experiment2 |

  @javascript
  Scenario: Changing the sort goes to the first page for new list
    When I have data files
      | filename    | created_at       | uploaded_by              | file_processing_status | experiment  |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au    | RAW                    | Experiment4 |
      | sample2.txt | 01/12/2011 12:45 | kali@intersect.org.au    | CLEANSED               | Experiment2 |
      | sample3.txt | 01/12/2011 11:45 | admin@intersect.org.au   | RAW                    | Experiment5 |
      | sample4.txt | 01/12/2011 10:45 | matthew@intersect.org.au | CLEANSED               | Experiment1 |
      | sample5.txt | 01/12/2011 09:45 | admin@intersect.org.au   | RAW                    | Experiment3 |
    And I am on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by              | Type     | Experiment  |
      | sample1.txt | 2011-12-01 13:45 | sean@intersect.org.au | RAW      | Experiment4 |
      | sample2.txt | 2011-12-01 12:45 | kali@intersect.org.au | CLEANSED | Experiment2 |
  #    And I should not see link "1" in "the pagination area"
  #    And I should not see link "Previous" in "the pagination area"
    When I follow "Date added" within the exploredata table
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by                 | Type     | Experiment  |
      | sample5.txt | 2011-12-01 9:45  | admin@intersect.org.au   | RAW      | Experiment3 |
      | sample4.txt | 2011-12-01 10:45 | matthew@intersect.org.au | CLEANSED | Experiment1 |
#    And I should not see link "1" in "the pagination area"
#    And I should not see link "Previous" in "the pagination area"

  @javascript
  Scenario: Changing the search criteria goes to the first page of the new list
    When I have data files
      | filename    | created_at       | uploaded_by              | file_processing_status | experiment  |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au    | RAW                    | Experiment4 |
      | sample2.txt | 01/12/2011 12:45 | kali@intersect.org.au    | CLEANSED               | Experiment2 |
      | sample3.txt | 01/12/2011 11:45 | admin@intersect.org.au   | RAW                    | Experiment5 |
      | sample4.txt | 01/12/2011 10:45 | matthew@intersect.org.au | CLEANSED               | Experiment1 |
      | sample5.txt | 01/12/2011 09:45 | admin@intersect.org.au   | RAW                    | Experiment3 |
    And I am on the list data files page
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by              | Type     | Experiment  |
      | sample1.txt | 2011-12-01 13:45 | sean@intersect.org.au | RAW      | Experiment4 |
      | sample2.txt | 2011-12-01 12:45 | kali@intersect.org.au | CLEANSED | Experiment2 |
  #    And I should not see link "1" in "the pagination area"
  #    And I should not see link "Previous" in "the pagination area"
    When I follow "2" within the pagination area
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by                 | Type     | Experiment  |
      | sample3.txt | 2011-12-01 11:45 | admin@intersect.org.au   | RAW      | Experiment5 |
      | sample4.txt | 2011-12-01 10:45 | matthew@intersect.org.au | CLEANSED | Experiment1 |
  #    And I should not see link "2" in "the pagination area"
    And I follow Showing
    When I click on "Type:" within the search box
    And I check "RAW"
    And I press "Update Search Results"
    Then I should see "exploredata" table with
      | Filename    | Date added       | Added by               | Type | Experiment  |
      | sample1.txt | 2011-12-01 13:45 | sean@intersect.org.au  | RAW  | Experiment4 |
      | sample3.txt | 2011-12-01 11:45 | admin@intersect.org.au | RAW  | Experiment5 |
#    And I should not see link "1" in "the pagination area"
#    And I should not see link "Previous" in "the pagination area"
