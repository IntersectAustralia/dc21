Feature: Navigation between pages across the site

  Background:
    Given I am logged in as "georgina@intersect.org.au"

  Scenario: There should be tabs for dashboard, data files and facilities on home page
    Given I am on the home page
    Then I should see link "Dashboard"
    And I should see link "Explore Data"
    And I should see link "Facilities"

  Scenario: Clicking tabs direct to correct page - data files tab
    Given I am on the home page
    When I follow "Explore Data"
    Then I should be on the list data files page

  Scenario: Clicking tabs direct to correct page - facilities tab
    Given I am on the home page
    When I follow "Facilities"
    Then I should be on the facilities page

  Scenario: Clicking tabs direct to correct page - home page
    Given I am on the home page
    When I follow "Facilities"
    And I follow "Dashboard"
    Then I should be on the home pages page

  Scenario: There should be tabs for users, access requests and column mappings under admin
    Given I am on the users page
    Then I should see link "Users"
    And I should see link "Access Requests"
    And I should see link "Column Mappings"

  Scenario: Clicking tabs direct to correct page - access requests tab
    Given I am on the users page
    When I follow "Access Requests"
    Then I should be on the access requests users page

  Scenario: Clicking tabs direct to correct page - column mapping tab
    Given I am on the users page
    When I follow "Column Mappings"
    Then I should be on the column mappings page

  Scenario: Clicking tabs direct to correct page - users page
    Given I am on the users page
    When I follow "Column Mappings"
    And I follow "Users"
    Then I should be on the users page

  Scenario: Should be links for about and admin in top navigation bar
    Given I am on the home page
    Then I should see link "About"
    Then I should see link "Admin"

  Scenario: Clicking about link in top navigation bar directs to correct page
    Given I am on the home page
    When I follow "About"
    Then I should be on the about pages page

  Scenario: Clicking admin link in top navigation bar directs to correct page
    Given I am on the home page
    When I follow "Admin"
    Then I should be on the users page
