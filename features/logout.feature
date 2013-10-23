Feature: Logging Out
  In order to keep the system secure
  As a user
  I want to logout

  Background:
    Given I have a user "admin@intersect.org.au"
    And I am on the login page
    And I am logged in as "admin@intersect.org.au"
    And I should see "Logged in successfully."

  Scenario: Successful logout
    Given I am on the home page
    When I follow "Sign out"
    Then I should see "Logged out successfully."

  Scenario: Logged out user can't access secure pages
    Given I am on the list users page
    And I follow "Sign out"
    When I am on the list users page
    Then I should be on the login page
    And I should see "You need to log in before continuing."
