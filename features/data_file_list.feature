Feature: View the list of data files
  In order to find what I need
  As a user
  I want to view a list of data files

  Background:
    Given I am logged in as "georgina@intersect.org.au"

  Scenario: View the list
    Given I have data files
      | filename     |
      | sample.txt   |
      | datafile.dat |
    When I am on the list data files page
    Then I should see "data_files" table with
      | Name         |
      | datafile.dat |
      | sample.txt   |

  Scenario: View the list when there's nothing to show
    When I am on the list data files page
    Then I should see "No files to display."

  Scenario: Must be logged in to view the list
    Then users should be required to login on the list data files page