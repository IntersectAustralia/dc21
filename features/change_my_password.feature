Feature: Change my password
  In order to keep my account secure
  As a user
  I want to change my password

  Background:
    Given I have a user "admin@intersect.org.au"
    And I am logged in as "admin@intersect.org.au"

  Scenario: Change password
    When I attempt to change my password with old password "Pas$w0rd", new password "Pass.123" and confirmation "Pass.123"
    Then I should see "Your password has been updated."
    And I should see link "Sign out"
    And I should be able to log in with "admin@intersect.org.au" and "Pass.123"

  Scenario: Change password not allowed if current password is empty
    When I attempt to change my password with old password "", new password "Pass.123" and confirmation "Pass.123"
    Then I should see "Current password can't be blank"
    And I should be able to log in with "admin@intersect.org.au" and "Pas$w0rd"

  Scenario: Change password not allowed if current password is incorrect
    When I attempt to change my password with old password "asdf", new password "Pass.123" and confirmation "Pass.123"
    Then I should see "Current password is invalid"
    And I should be able to log in with "admin@intersect.org.au" and "Pas$w0rd"

  Scenario: Change password not allowed if confirmation doesn't match new password
    When I attempt to change my password with old password "Pas$w0rd", new password "Pass.123" and confirmation "Pass.1233"
    Then I should see "Password doesn't match confirmation"
    And I should be able to log in with "admin@intersect.org.au" and "Pas$w0rd"

  Scenario: Change password not allowed if new password blank
    When I attempt to change my password with old password "Pas$w0rd", new password "" and confirmation ""
    Then I should see "Password can't be blank"
    And I should be able to log in with "admin@intersect.org.au" and "Pas$w0rd"

  Scenario: Change password not allowed if new password doesn't meet password rules
    When I attempt to change my password with old password "Pas$w0rd", new password "Pass.abc" and confirmation "Pass.abc"
    Then I should see "Password must be between 6 and 20 characters long and contain at least one uppercase letter, one lowercase letter, one digit and one symbol"
    And I should be able to log in with "admin@intersect.org.au" and "Pas$w0rd"
