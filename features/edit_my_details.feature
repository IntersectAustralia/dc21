Feature: Edit my details
  In order to keep my details up to date
  As a user
  I want to edit my details

  Background:
    Given I have a user "admin@intersect.org.au" with name "admin" "Edwards"
    And I am logged in as "admin@intersect.org.au"

  Scenario: Edit my information
    Given I am on the home page
    When I follow "Settings"
    And I follow "Edit Details"
    And I fill in "First Name" with "Fred"
    And I fill in "Last Name" with "Bloggs"
    And I press "Update"
    Then I should see "Your account details have been successfully updated."
    And I should be on the user profile page
    And I should see "Fred"
    And I should see "Bloggs"

  Scenario: Validation error
    Given I am on the edit my details page
    And I fill in "First Name" with ""
    And I fill in "Last Name" with "Bloggs"
    And I press "Update"
    Then I should see "First name can't be blank"

  Scenario: Cancel editing my information
    Given I am on the edit my details page
    And I follow "Edit Details"
    And I fill in "Last Name" with "Bloggs"
    And I follow "Cancel"
    Then I should be on the user profile page
    And I should see "Edwards"
    And I should not see "Bloggs"
