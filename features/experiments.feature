Feature: Manage experiment parameter metadata
  In order to make data more useful to others
  As a researcher
  I want to describe the parameters of my experiment

  Background:
    Given I am logged in as "admin@intersect.org.au"

  Scenario: View the list
    Given I have facilities
      | name      | code |
      | Facility0 | f0   |
      | Facility1 | f1   |
    When I am on the facilities page
    Then I should see "facilities" table with
      | Name      | Code |
      | Facility0 | f0   |
      | Facility1 | f1   |

  Scenario: Facilities list should be ordered by name
    Given I have facilities
      | name      | code |
      | Facility2 | f2   |
      | Facility1 | f1   |
      | Facility4 | f4   |
      | Facility0 | f0   |
      | Facility3 | f3   |
    When I am on the facilities page
    Then I should see "facilities" table with
      | Name      | Code |
      | Facility0 | f0   |
      | Facility1 | f1   |
      | Facility2 | f2   |
      | Facility3 | f3   |
      | Facility4 | f4   |

  Scenario: Create an experiment with only start date
    Given I have facilities
      | name      | code | description | a_lat      | a_long    | b_lat      | b_long    |
      | Facility0 | f0   | abcdefg     | -33.856557 | 151.21460 | -33.856657 | 151.21550 |
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I have filled in the basic fields on the new experiment page under facility "Facility0"
    And I press "Save Experiment"

  Scenario: Create an experiment with no dates
    Given I have facilities
      | name      | code | description | a_lat      | a_long    | b_lat      | b_long    |
      | Facility0 | f0   | abcdefg     | -33.856557 | 151.21460 | -33.856657 | 151.21550 |
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I have filled in no dates on the new experiment page under facility "Facility0"
    And I press "Save Experiment"
    Then I should see "Start date can't be blank"

  Scenario: Create an experiment with end date before start date
    Given I have facilities
      | name      | code | description | a_lat      | a_long    | b_lat      | b_long    |
      | Facility0 | f0   | abcdefg     | -33.856557 | 151.21460 | -33.856657 | 151.21550 |
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I have filled in end date before start date on the new experiment page under facility "Facility0"
    And I press "Save Experiment"
    Then I should see "End date cannot be before start date"

  Scenario: Create an experiment with invalid dates
    Given I have facilities
      | name      | code | description | a_lat      | a_long    | b_lat      | b_long    |
      | Facility0 | f0   | abcdefg     | -33.856557 | 151.21460 | -33.856657 | 151.21550 |
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I have filled in invalid dates on the new experiment page under facility "Facility0"
    And I press "Save Experiment"
    Then I should see "End date must be a valid date"
    Then I should see "Start date must be a valid date"