@javascript
Feature: Create a package
  In order to handle multiple data files which belong to a group
  As a user
  I want to bundle them into a package for upload/download

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have data files
      | filename     |
      | datafile.dat |
      | sample.txt   |
      | sample2.txt  |

  Scenario: Package is now available as a file type to search on
    Given I am on the list data files page
    And I click on "Type:"
    Then I should see "PACKAGE"

  #Scenario: New package form
  #  Given I am on the list data files page
  #  And I add sample.txt to the cart
  #  And I add datafile.dat to the cart
  #  When I am on the create package page
  #  Then I should see

