Feature: Logging In
  In order to use the system
  As an AAF user
  I want to login via AAF

  Background:
    Given I have the usual roles
    And I have a user "admin@intersect.org.au"
    And "admin@intersect.org.au" has role "Administrator"

  Scenario: Display AAF notes
    Given I am on the login page
    Then I should see "Note: This will take you to the AAF (Australian Access Federation) login page."
    And I should see "Log in via AAF"

  Scenario: Successful login via AAF
    Given I log in via AAF as "admin@intersect.org.au"
    And I am on the home page
    And I should be on the home page
    Then I should see "Home / Dashboard"
    And I should see "admin@intersect.org.au"
    And I should see "Admin"

  Scenario: Login via AAF with inactive account
    Given I have a pending approval user "inactive@intersect.org.au"
    Given I log in via AAF as "inactive@intersect.org.au"
    And I am on the home page
    And I should be on the home page
    And I should see "inactive@intersect.org.au (via AAF)"
    And I should see "Note: You are logged in via AAF as inactive@intersect.org.au"
    And I should see "but you are not yet authorised to use HIEv."

  Scenario: Login via AAF with unregistered account prefills values
    Given I log in via AAF as "unregistered@intersect.org.au"
    And I am on the home page
    And I should be on the request account page
    And I should see "unregistered@intersect.org.au"
    And I should see "You must be an approved user to access this site"
    And the "First Name" field should contain "Test"
    And the "Last Name" field should contain "AAF"
    And I follow "Cancel"
    And I should be on the login page
    And I should see "unregistered@intersect.org.au (via AAF)"
    And I should see "Note: You are logged in via AAF as unregistered@intersect.org.au"
    And I should see "but you are not yet authorised to use HIEv."

  Scenario: Login via AAF with inactive account and log in with database
    Given I have a pending approval user "inactive@intersect.org.au"
    Given I log in via AAF as "inactive@intersect.org.au"
    And I am on the home page
    And I should be on the home page
    And I should see "inactive@intersect.org.au (via AAF)"
    And I should see "Note: You are logged in via AAF as inactive@intersect.org.au"
    And I should see "but you are not yet authorised to use HIEv."
    When I fill in "Email" with "admin@intersect.org.au"
    And I fill in "Password" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Logged in successfully."
    And I should be on the home page

  Scenario: Login via AAF with unregistered account and log in with database
    Given I log in via AAF as "unregistered@intersect.org.au"
    And I am on the home page
    And I should be on the request account page
    And I should see "You must be an approved user to access this site"
    And I follow "Cancel"
    And I should be on the login page
    And I should see "unregistered@intersect.org.au (via AAF)"
    When I fill in "Email" with "admin@intersect.org.au"
    And I fill in "Password" with "Pas$w0rd"
    And I press "Log in"
    Then I should see "Logged in successfully."
    And I should be on the home page

  Scenario: Sign up should still work if request headers are empty strings
    Given the Shibboleth headers are empty
    And I am on the request account page
    And I should be on the request account page
    When I fill in the following:
      | Email            | unregistered@intersect.org.au |
      | Password         | paS$w0rd                      |
      | Confirm Password | paS$w0rd                      |
      | First Name       | Fred                          |
      | Last Name        | Bloggs                        |
    And I press "Submit Request"
    Then I should see "Thanks for requesting an account. You will receive an email when your request has been approved."
    And I should not see "Your account is not active"
    And I should be on the home page
    And I should see "Please enter your email and password to log in"

