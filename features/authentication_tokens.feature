@javascript
Feature: Create and manage authentication tokens
  In order to use the system via an API
  As a user
  I want to manage my authentication token

  Background:
    Given I have the usual roles
    And I have a user "diego@intersect.org.au" with role "Researcher"
    And I am logged in as "diego@intersect.org.au"
    When I click on "diego@intersect.org.au"
    And I click on "Settings"

  Scenario: New user has no token
    Then I should see no api token
    And I should see link "Generate Token"

  Scenario: Generate a token
    When I follow "Generate Token"
    Then I should see the api token displayed for user "diego@intersect.org.au"
    And I should not see link "Generate Token"
    And I should see link "Re-generate Token"

  Scenario: Re-generate a token
    When I follow "Generate Token"
    And I follow "Re-generate Token"
    Then The popup text should contain "Are you sure you want to regenerate your token? You will need to update any scripts that used the previous token."
    When I confirm the popup
    Then I should see the api token displayed for user "diego@intersect.org.au"

  Scenario: Delete a token
    When I follow "Generate Token"
    And I follow "Delete Token"
    Then The popup text should contain "Are you sure you want to delete your token? You will no longer be able to perform API actions."
    When I confirm the popup
    Then I should see no api token

  Scenario: Tokens can't be used on non-API actions
    And I follow "Generate Token"
    Then I should see the api token displayed for user "diego@intersect.org.au"
    When I make a request for the explore data page with the API token for "diego@intersect.org.au"
    Then I should get a 401 response code

