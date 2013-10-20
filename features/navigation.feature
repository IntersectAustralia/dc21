Feature: Navigation between pages across the site

  Background:
    Given I am logged in as "admin@intersect.org.au"

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

  Scenario: Should be link for admin in top navigation bar
    Given I am on the home page
    Then I should see link "Admin"

  Scenario: Clicking admin link in top navigation bar directs to correct page
    Given I am on the home page
    When I follow "Admin"
    Then I should be on the users page

  Scenario: There should be tabs for overview, edit details and change password under own user settings
    Given I am on the users profile page
    Then I should see link "Overview"
    And I should see link "Edit Details"
    And I should see link "Change Password"

  Scenario: Clicking tabs direct to correct page - edit details tab
    Given I am on the users profile page
    When I follow "Edit Details"
    Then I should be on the edit user registration page

  Scenario: Clicking tabs direct to correct page - change password tab
    Given I am on the users profile page
    When I follow "Change Password"
    Then I should be on the users edit password page

  Scenario: Clicking tabs direct to correct page - users profile page
    Given I am on the users profile page
    When I follow "Change Password"
    And I follow "Overview"
    Then I should be on the users profile page

  @javascript
  Scenario: Editing own user details
    Given I am on the home page
    When I click on "admin@intersect.org.au"
    And I sleep briefly
    And I follow "Settings"
    Then I should be on the users profile page

  @javascript
  Scenario: Logging out through dropdown
    Given I am on the home page
    When I click on "admin@intersect.org.au"
    And I follow "Sign out"
    Then I should see "Logged out successfully."
