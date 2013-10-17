Feature: Administer System
  In order to allow Admins to configure the system
  As an administrator
  I want to administer the system

  Background:
    Given I have users
      | email                     | first_name | last_name |
      | raul@intersect.org.au     | Raul       | Carrizo   |
      | georgina@intersect.org.au | Georgina   | Edwards   |
    And I have the usual roles
    And I am logged in as "georgina@intersect.org.au"
    And "georgina@intersect.org.au" has role "Administrator"

  Scenario: View system details
    Given "georgina@intersect.org.au" has role "Administrator"
    And I am on the view system page
    When I follow "View System Configuration" for "georgina@intersect.org.au"
    Then I should see details displayed
      | Email      | raul@intersect.org.au |
      | First name | Raul                  |
      | Last name  | Carrizo               |
      | Role       | Researcher            |
      | Status     | Active                |

  Scenario: Go back from user details
    Given I am on the list users page
    When I follow "View Details" for "georgina@intersect.org.au"
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

  Scenario: Cancel out of editing roles
    Given "raul@intersect.org.au" has role "Researcher"
    And I am on the list users page
    When I follow "View Details" for "raul@intersect.org.au"
    And I follow "Edit role"
    And I select "Administrator" from "Role"
    And I follow "Back"
    Then I should be on the user details page for raul@intersect.org.au
    And I should see field "Role" with value "Researcher"

  Scenario: Role should be mandatory when editing Role
    And I am on the list users page
    When I follow "View Details" for "raul@intersect.org.au"
    And I follow "Edit role"
    And I select "" from "Role"
    And I press "Update"
    Then I should see "Please select a role for the user."

  Scenario: Editing own role has alert
    Given I am on the list users page
    When I follow "View Details" for "georgina@intersect.org.au"
    And I follow "Edit role"
    Then I should see "You are changing the role of the user you are logged in as."
