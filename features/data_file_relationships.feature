Feature: Edit data file relationships
  As a Researcher
  I want to define parent/child relationships between files
  so that I can capture the provenance / currency of a file

  Background:
    Given I have a user "admin@intersect.org.au" with role "Administrator"
    Given I have a user "researcher@intersect.org.au" with role "Institutional User"
    And I have data files
      | filename             | created_at       | uploaded_by                 | start_time        | end_time            | interval | experiment           | file_processing_description       | file_processing_status | format | label_list        | transfer_status | uuid  |
      | datafile.dat         | 30/11/2011 10:15 | admin@intersect.org.au      |                   |                     |          | My Nice Experiment   | Description of my file            | RAW                    |        |                   |                 |       |
      | sample.txt           | 01/12/2011 13:45 | sean@intersect.org.au       | 1/6/2010 15:23:00 | 30/11/2011 12:00:00 | 300      | Other                |                                   | UNKNOWN                | TOA5   |                   |                 |       |
      | file.txt             | 02/11/2011 14:00 | researcher@intersect.org.au | 1/5/2010 14:00:00 | 2/6/2011 13:00:00   |          | Silly Experiment     | desc.                             | UNKNOWN                |        |                   |                 |       |
      | error.txt            | 03/13/2011 14:00 | researcher@intersect.org.au | 1/5/2010 14:00:00 | 2/6/2011 13:00:00   |          | Expt1                | desc.                             | ERROR                  |        |                   |                 |       |
      | file_with_labels.txt | 04/11/2013 15:45 | cindy@intersect.org.au      |                   |                     |          | Delete Label Example | Test deleting a label from a file | UNKNOWN                |        | this3,that2,test1 | WORKING         | 12345 |

  @javascript
  Scenario: Edit and view relationships
    Given I am logged in as "admin@intersect.org.au"
    And I am on the data file details page for sample.txt
    And I should see details displayed
      | Parents  | No parent files defined.   |
      | Children | No children files defined. |
    And I am on the edit data file page for sample.txt
    Then I should see "sample.txt"
    And I should see "3"
    And I should see "sean@intersect.org.au"
    And "Other" should be selected in the "Experiment" select
  # test that you can't add current data file
    When I fill in "Parents" with "sample.txt"
    Then I should see "No matches found"
    When I fill in "Children" with "datafile.dat"
    Then I should see "No matches found"

    And I select "Expt1" from "Filter Files"
    And I wait for 2 seconds
    And I fill in "Children" with "error.txt"
    And I should see "error.txt"
    And I choose "error.txt" in the select2 menu
  # test that data file from other experiment can't be added to parent
    When I fill in "Parents" with "error"
    Then I should see "No matches found"

    And I press "Update"
  # test that child file displays parent file as well
    And I should be on the data file details page for sample.txt
    And I should see details displayed
      | Parents  | No parent files defined. |
      | Children | error.txt                |
    And I follow "error.txt"
    And I should be on the data file details page for error.txt
    And I should see details displayed
      | Parents  | sample.txt                 |
      | Children | No children files defined. |


  @javascript
  Scenario: Add related files excludes incomplete files
    Given I am logged in as "admin@intersect.org.au"
    And I should see "0 Files in Cart"
    And I have data files
      | filename    | created_at       | uploaded_by            | parents      | children                                              |
      | related.txt | 30/11/2011 10:15 | admin@intersect.org.au | datafile.dat | sample.txt, file.txt, error.txt, file_with_labels.txt |
    And I am on the data file details page for related.txt
    And I should see "0 Files in Cart"
    And I should see details displayed
      | Parents  | datafile.dat                                          |
      | Children | error.txt\nfile.txt\nfile_with_labels.txt\nsample.txt |
    And I follow "Add All Related Files to Cart"
    And I should see "5 files were added to your cart. 1 items were not added due to problems."
    And I should see "5 Files in Cart"

  @javascript
  Scenario: Delete related files
    Given I am logged in as "admin@intersect.org.au"
    And I should see "0 Files in Cart"
    And I have data files
      | filename    | created_at       | uploaded_by            | parents      | children                                              |
      | related.txt | 30/11/2011 10:15 | admin@intersect.org.au | datafile.dat | sample.txt, file.txt, error.txt, file_with_labels.txt |
    And I am on the data file details page for related.txt
    And I am on the edit data file page for related.txt
    And I should see "sample.txt"
    And I should see "datafile.dat"
    And I should see "file.txt"
    And I should see "error.txt"
    And I should see "file_with_labels.txt"
    And I remove "datafile.dat" from the select2 field
    And I remove "sample.txt" from the select2 field
    And I remove "file.txt" from the select2 field
    And I remove "error.txt" from the select2 field
    And I remove "file_with_labels.txt" from the select2 field
    And I wait for 2 seconds
    And I press "Update"
    And I should be on the data file details page for related.txt
    And I should see details displayed
      | Parents  | No parent files defined.   |
      | Children | No children files defined. |

#EYETRACKER-170
  @javascript
  Scenario: Single upload new parent relationship
    Given I am logged in as "admin@intersect.org.au"
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "Other" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample2.txt" to upload
    And I select "My Nice Experiment" from "Filter Files"
    And I should not see "Children"
    When I fill in "Parents" with "datafile.dat"
    And I wait for 2 seconds
    And I choose "datafile.dat" in the select2 menu
    And I press "Upload"
    Then the most recent file should have name "sample2.txt"
    And the uploaded files display should include "sample2.txt" with file type "RAW"
    And the uploaded files display should include "sample2.txt" with messages "success"
    And the uploaded files display should include "sample2.txt" with experiment "Other"
    And the uploaded files display should include "sample2.txt" with description "My descriptive description"
    And file "sample2.txt" should have type "RAW"
    And file "sample2.txt" should have experiment "Other"
    And file "sample2.txt" should have description "My descriptive description"
    And file "sample2.txt" should have parents "datafile.dat"
    Then I press "Update"
    When I am on the list data files page
    And I follow the view link for data file "sample2.txt"
    And I wait for 1 seconds
    Then I should see details displayed
      | Parents  | datafile.dat               |
      | Children | No children files defined. |

#EYETRACKER-170
  @javascript
  Scenario: Remove parent after uploading parent relationship
    Given I am logged in as "admin@intersect.org.au"
    Given I am on the upload page
    When I select "RAW" from "File type"
    And I select "Other" from "Experiment"
    And I fill in "Description" with "My descriptive description"
    And I select "samples/sample1.txt" to upload
    And I select "My Nice Experiment" from "Filter Files"
    And I should not see "Children"
    When I fill in "Parents" with "datafile.dat"
    And I wait for 2 seconds
    And I choose "datafile.dat" in the select2 menu
    And I press "Upload"
    Then the most recent file should have name "sample1.txt"
    And the uploaded files display should include "sample1.txt" with file type "RAW"
    And the uploaded files display should include "sample1.txt" with messages "success"
    And the uploaded files display should include "sample1.txt" with experiment "Other"
    And the uploaded files display should include "sample1.txt" with description "My descriptive description"
    And file "sample1.txt" should have type "RAW"
    And file "sample1.txt" should have experiment "Other"
    And file "sample1.txt" should have description "My descriptive description"
    And file "sample1.txt" should have parents "datafile.dat"
    And I remove "datafile.dat" from the select2 field
    And I wait for 2 seconds
    Then I press "Update"
    When I am on the list data files page
    And I follow the view link for data file "sample1.txt"
    And I wait for 1 seconds
    Then I should see details displayed
      | Parents  | No parent files defined.   |
      | Children | No children files defined. |

#EYETRACKER-170
  Scenario: Multiple mass upload parent relationship
# This cannot be automated due to limitations with selenium+file uploads - see manual tests

