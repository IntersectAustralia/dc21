Feature: Administer users
  In order to allow users to access the system
  As an administrator
  I want to administer users

  Background:
    Given I have users
      | email                  | first_name | last_name |
      | raul@intersect.org.au  | Raul       | Carrizo   |
      | admin@intersect.org.au | admin      | Edwards   |
    And I have the usual roles
    And I am logged in as "admin@intersect.org.au"
    And "admin@intersect.org.au" has role "Administrator"

  Scenario: View a list of users
    Given "raul@intersect.org.au" is deactivated
    When I am on the list users page
    Then I should see "users" table with
      | Email                  | First name | Last name | Role          | Status      |
      | admin@intersect.org.au | admin      | Edwards   | Administrator | Active      |
      | raul@intersect.org.au  | Raul       | Carrizo   |               | Deactivated |

  Scenario: View user details
    Given "raul@intersect.org.au" has role "Institutional User"
    And I am on the list users page
    When I follow "View Details" for "raul@intersect.org.au"
    Then I should see details displayed
      | Email      | raul@intersect.org.au |
      | First name | Raul                  |
      | Last name  | Carrizo               |
      | Role       | Institutional User    |
      | Status     | Active                |

  Scenario: Go back from user details
    Given I am on the list users page
    When I follow "View Details" for "admin@intersect.org.au"
    And I follow "Back"
    Then I should be on the list users page

  Scenario: Edit role
    Given "raul@intersect.org.au" has role "Researcher"
    And I am on the list users page
    When I follow "View Details" for "raul@intersect.org.au"
    And I follow "Edit role"
    And I select "Administrator" from "Role"
    And I press "Update"
    Then I should be on the user details page for raul@intersect.org.au
    And I should see "The role for raul@intersect.org.au was successfully updated."
    And I should see field "Role" with value "Administrator"

  Scenario: Edit role from list page
    Given "raul@intersect.org.au" has role "Researcher"
    And I am on the list users page
    When I follow "Edit role" for "raul@intersect.org.au"
    And I select "Administrator" from "Role"
    And I press "Update"
    Then I should be on the user details page for raul@intersect.org.au
    And I should see "The role for raul@intersect.org.au was successfully updated."
    And I should see field "Role" with value "Administrator"

  Scenario: Cancel out of editing roles
    Given "raul@intersect.org.au" has role "Institutional User"
    And I am on the list users page
    When I follow "View Details" for "raul@intersect.org.au"
    And I follow "Edit role"
    And I select "Administrator" from "Role"
    And I follow "Back"
    Then I should be on the user details page for raul@intersect.org.au
    And I should see field "Role" with value "Institutional User"

  Scenario: Role should be mandatory when editing Role
    And I am on the list users page
    When I follow "View Details" for "raul@intersect.org.au"
    And I follow "Edit role"
    And I select "" from "Role"
    And I press "Update"
    Then I should see "Please select a role for the user."

  Scenario: Deactivate active user
    Given I am on the list users page
    When I follow "View Details" for "raul@intersect.org.au"
    And I follow "Deactivate"
    Then I should see "The user has been deactivated"
    And I should see "Activate"

  Scenario: Activate deactivated user
    Given "raul@intersect.org.au" is deactivated
    And I am on the list users page
    When I follow "View Details" for "raul@intersect.org.au"
    And I follow "Activate"
    Then I should see "The user has been activated"
    And I should see "Deactivate"

  Scenario: Can't deactivate the last administrator account
    Given I am on the list users page
    When I follow "View Details" for "admin@intersect.org.au"
    And I follow "Deactivate"
    Then I should see "You cannot deactivate this account as it is the only account with Administrator privileges."
    And I should see field "Status" with value "Active"

  Scenario: Editing own role has alert
    Given I am on the list users page
    When I follow "View Details" for "admin@intersect.org.au"
    And I follow "Edit role"
    Then I should see "You are changing the role of the user you are logged in as."

  Scenario: Should not be able to edit role of rejected user by direct URL entry
    Given I have a rejected as spam user "spam@intersect.org.au"
    And I go to the edit role page for spam@intersect.org.au
    Then I should be on the list users page
    And I should see "Role can not be set. This user has previously been rejected as a spammer."

