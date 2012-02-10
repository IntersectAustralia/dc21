Feature: Manage experiment metadata
  In order to make data more useful to others
  As a researcher
  I want to manage metadata about experiments

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have experiments
      | name             | description    | start_date | end_date   | subject |
      | Weather Station  | Blah Blah Blah | 2011-10-30 |            | Rain    |
      | Tree Chambers 01 | Whatever       | 2012-01-15 | 2013-01-01 | Trees   |

  Scenario: View the list of experiments
    When I am on the experiments page
    Then I should see "experiments" table with
      | Name             | Start date | End date   | Subject |
      | Tree Chambers 01 | 2012-01-15 | 2013-01-01 | Trees   |
      | Weather Station  | 2011-10-30 |            | Rain    |

  Scenario: View the list when there's nothing to show
    Given I have no experiments
    When I am on the experiments page
    Then I should see "There are no experiments to display"

  Scenario: Must be logged in to view the experiments list, details, create, edit pages
    Then users should be required to login on the experiments page
    Then users should be required to login on the view experiment page for 'Weather Station'
    Then users should be required to login on the edit experiment page for 'Weather Station'
    Then users should be required to login on the new experiment page

  Scenario: View an experiment
    When I am on the experiments page
    And I follow the view link for experiment "Tree Chambers 01"
    Then I should see details displayed
      | Name        | Tree Chambers 01 |
      | Description | Whatever         |
      | Start date  | 2012-01-15       |
      | End date    | 2013-01-01       |
      | Subject     | Trees            |
    When I follow "Back"
    Then I should be on the experiments page

#
#  Scenario: Create a new facility
#    Given I am on the facilities page
#    And I follow "New Facility"
#    When I fill in the following:
#      | facility_name | Facility0 |
#      | facility_code | f0        |
#    And I press "Save Facility"
#    Then I should see "Facility successfully added"
#    And I should see details displayed
#      | Name | Facility0 |
#      | Code | f0        |
#
#  Scenario: Create a new facility with invalid details
#    Given I am on the facilities page
#    And I follow "New Facility"
#    When I fill in the following:
#      | facility_name |  |
#      | facility_code |  |
#    And I press "Save Facility"
#    Then I should see "Name can't be blank"
#    And I should see "Code can't be blank"
#
#  Scenario: Create a duplicate facility
#    Given I have facilities
#      | name      | code |
#      | Facility0 | f0   |
#    When I am on the facilities page
#    And I follow "New Facility"
#    When I fill in the following:
#      | facility_name | Facility0 |
#      | facility_code | f0        |
#    And I press "Save Facility"
#    Then I should see "Name has already been taken"
#    Then I should see "Code has already been taken"
#
#  Scenario: Navigate back to the list of facilities from create screen
#    Given I am on the facilities page
#    And I follow "New Facility"
#    And I follow "Cancel"
#    Then I should be on the facilities page
#
#  Scenario: Edit the details of a facility
#    Given I have facilities
#      | name      | code |
#      | Facility0 | f0   |
#    When I am on the facilities page
#    And I follow the view link for facility "Facility0"
#    And I follow "Edit Facility"
#    And I fill in the following:
#      | facility_name | Facility1 |
#      | facility_code | fac1      |
#    And I press "Update"
#    Then I should see "Facility successfully updated."
#    And I should see details displayed
#      | Name | Facility1 |
#      | Code | fac1      |
#
#  Scenario: Edit the details of a facility to something invalid
#    Given I have facilities
#      | name      | code |
#      | Facility0 | f0   |
#    When I am on the facilities page
#    And I follow the view link for facility "Facility0"
#    And I follow "Edit Facility"
#    And I fill in the following:
#      | facility_name | really_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_namereally_long_name |
#      | facility_code |                                                                                                                                                                                                                                                                                                                                                                                  |
#    And I press "Update"
#    Then I should see "Code can't be blank"
#    And I should see "Name is too long (maximum is 50 characters)"
#
#  Scenario: Edit the details of a facility to become a duplicate
#    Given I have facilities
#      | name      | code |
#      | Facility0 | f0   |
#      | Facility1 | f1   |
#    When I am on the facilities page
#    And I follow the view link for facility "Facility0"
#    And I follow "Edit Facility"
#    And I fill in the following:
#      | facility_name | Facility1 |
#      | facility_code | f1        |
#    And I press "Update"
#    Then I should see "Name has already been taken"
#    And I should see "Code has already been taken"
#
#  Scenario: Cancelling the edit of a facility
#    Given I have facilities
#      | name      | code |
#      | Facility0 | f0   |
#    When I am on the facilities page
#    And I follow the view link for facility "Facility0"
#    And I follow "Edit Facility"
#    And I fill in the following:
#      | facility_name | Facility1 |
#      | facility_code | f1        |
#    And I follow "Cancel"
#    Then I should see details displayed
#      | Name | Facility0 |
#      | Code | f0        |
#
#  Scenario: Navigate back to the list of facilities from edit screen
#    Given I have facilities
#      | name      | code |
#      | Facility0 | f0   |
#    When I am on the facilities page
#    And I follow the view link for facility "Facility0"
#    And I follow "Edit Facility"
#    And I follow "Cancel"
#    Then I should see details displayed
#      | Name | Facility0 |
#      | Code | f0        |
#
