#EYETRACKER-138 #EYETRACKER-112
Feature: Permissions on Resque processed data files
  In order to manage my data
  As a administrator
  I want to make sure only I can modify erroneous or incomplete files in the system

  #only relies on your transfer status
  Background:
    Given I have a user "admin@intersect.org.au" with role "Administrator"
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    Given I have data files
      | filename        | uploaded_by                 | transfer_status | uuid | file_processing_status | path                | access_rights_type |
      | resque_queued   | researcher@intersect.org.au | QUEUED          | 1    | RAW                    | samples/sample1.txt |                    |
      | resque_working  | researcher@intersect.org.au | WORKING         | 1    | PACKAGE                | samples/sample1.txt | Open               |
      | resque_failed   | researcher@intersect.org.au | FAILED          | 1    | RAW                    | samples/sample1.txt |                    |
      | resque_complete | researcher@intersect.org.au | COMPLETE        | 1    | PACKAGE                | samples/sample1.txt | Restricted         |
      | non_resque      | researcher@intersect.org.au |                 |      | RAW                    | samples/sample1.txt |                    |

  Scenario: Admin users can edit any incomplete file
    And I am logged in as "admin@intersect.org.au"
    When I am on the edit data file page for resque_queued
    Then I should be on the edit data file page for resque_queued

    When I am on the edit data file page for resque_working
    Then I should be on the edit data file page for resque_working

    When I am on the edit data file page for resque_failed
    Then I should be on the edit data file page for resque_failed

    When I am on the edit data file page for resque_complete
    Then I should be on the edit data file page for resque_complete

    When I am on the edit data file page for non_resque
    Then I should be on the edit data file page for non_resque

  Scenario: Non-admin users cannot edit any incomplete file
    And I am logged in as "researcher@intersect.org.au"
    When I am on the edit data file page for resque_queued
    Then I should be on the data file details page for resque_queued
    Then I should see "Cannot edit - Creation status is not COMPLETE."

    When I am on the edit data file page for resque_working
    Then I should be on the data file details page for resque_working
    Then I should see "Cannot edit - Creation status is not COMPLETE."

    When I am on the edit data file page for resque_failed
    Then I should be on the edit data file page for resque_failed

    When I am on the edit data file page for resque_complete
    Then I should be on the edit data file page for resque_complete

    When I am on the edit data file page for non_resque
    Then I should be on the edit data file page for non_resque

  Scenario: Admin users can delete any incomplete file
    And I am logged in as "admin@intersect.org.au"
    And I visit the delete url for "resque_queued"
    Then I should be on the list data files page
    And I should see "The file 'resque_queued' was successfully removed."

    And I visit the delete url for "resque_working"
    Then I should be on the list data files page
    And I should see "The file 'resque_working' was successfully archived."

    And I visit the delete url for "resque_failed"
    Then I should be on the list data files page
    And I should see "The file 'resque_failed' was successfully removed."

    And I visit the delete url for "resque_complete"
    Then I should be on the list data files page
    And I should see "The file 'resque_complete' was successfully archived."

    And I visit the delete url for "non_resque"
    Then I should be on the list data files page
    And I should see "The file 'non_resque' was successfully removed."

  Scenario: Non-admin users can delete any incomplete file
    And I am logged in as "researcher@intersect.org.au"
    And I visit the delete url for "resque_queued"
    Then I should be on the data file details page for resque_queued
    Then I should see "Cannot delete - Creation status is not COMPLETE."

    And I visit the delete url for "resque_working"
    Then I should be on the data file details page for resque_working
    Then I should see "Cannot delete - Creation status is not COMPLETE."

    And I visit the delete url for "resque_failed"
    Then I should be on the list data files page
    And I should see "The file 'resque_failed' was successfully removed."

    And I visit the delete url for "resque_complete"
    Then I should be on the list data files page
    And I should see "The file 'resque_complete' was successfully archived."

    And I visit the delete url for "non_resque"
    Then I should be on the list data files page
    And I should see "The file 'non_resque' was successfully removed."

  Scenario Outline: Incomplete files cannot be added to the cart
    Given I am logged in as "<email>"
    And I am on the list data files page
    And I follow "Add All"
    And I should see "3 files were added to your cart. 2 items were not added due to problems."
    And I should see "3 Files in Cart"

  Examples:
    | email                       |
    | admin@intersect.org.au      |
    | researcher@intersect.org.au |


  Scenario Outline: Incomplete/failed files cannot be added to the cart
    Given I am logged in as "<email>"
    And I am on the list data files page

    When I am on the data file details page for resque_queued
    And I follow "Add to Cart"
    And I should see "File could not be added: The processing is not complete."

    When I am on the data file details page for resque_working
    And I follow "Add to Cart"
    And I should see "File could not be added: The processing is not complete."

    When I am on the data file details page for resque_failed
    And I follow "Add to Cart"
    And I should see "File was successfully added to cart."

    When I am on the data file details page for resque_complete
    And I follow "Add to Cart"
    And I should see "File was successfully added to cart."

    When I am on the data file details page for non_resque
    And I follow "Add to Cart"
    And I should see "File was successfully added to cart."

    And I should see "3 Files in Cart"

  Examples:
    | email                       |
    | admin@intersect.org.au      |
    | researcher@intersect.org.au |
