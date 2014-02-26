Feature: Admin users
  should be able to provide
  details about the application
  via a wysiwyg editor
  that is then displayed on the
  application home page

  Background:
    Given I have users
      | email                  | first_name | last_name |
      | raul@intersect.org.au  | Raul       | Carrizo   |
      | admin@intersect.org.au | admin      | Edwards   |
    And I have the usual roles
    And "admin@intersect.org.au" has role "Administrator"
    And "raul@intersect.org.au" has role "Researcher"

  Scenario: Admin adds description and is displayed
    Given I am logged in as "admin@intersect.org.au"
    And I am on the admin dashboard page
    And I fill in "bootsy_text_area" with "Hello and welcome to my test application, I hope you enjoy it."
    And I press "Update"
    When I am on the home page
    Then I should see "Hello and welcome to my test application, I hope you enjoy it."
    
  Scenario: non-admin users can not edit the dashboard content
    Given I am logged in as "raul@intersect.org.au"
    And I am on the admin dashboard page
    Then I should see "You are not authorized to access this page."
    And I should not see element with id "bootsy_text_area"