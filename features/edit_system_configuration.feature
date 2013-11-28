Feature: Edit system configuration
  In order to configure the system to my organisation's details
  As an administrator
  I want to edit the system name and other fields

  Background:
    Given I have users
      | email                     | first_name | last_name |
      | cindy@intersect.org.au    | Cindy      | Wang      |
      | georgina@intersect.org.au | Georgina   | Edwards   |
    And I have the usual roles
    And "georgina@intersect.org.au" has role "Administrator"
    And "cindy@intersect.org.au" has role "Researcher"

# EYETRACKER-1, # EYETRACKER-95

  Scenario: Edit system config fields as admin
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in "Name" with "Hello world"
    And I press "Update"
    Then I should see "System configuration updated successfully."

  Scenario: View system config fields as admin
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the system config page
    Then I should see details displayed
      | Local System Name    | HIEv                                          |
      | Research Centre Name | Hawkesbury Institute for the Environment      |
      | Overarching Entity   | University of Western Sydney                  |
      | Address              | Locked Bag 1797, Penrith NSW, 2751, Australia |
      | Telephone Numbers    | +61 2 4570 1125                               |
      | Email                | hieinfo@lists.uws.edu.au                      |
      | Description          |                                               |
      | URLs                 | http://www.uws.edu.au/hie                     |

  Scenario: Access system config edit page as non-admin
    Given I am logged in as "cindy@intersect.org.au"
    And I am on the edit system config page
    Then I should see "You are not authorized to access this page."
    And I am on the system config page
    Then I should see "You are not authorized to access this page."

  Scenario: Check all mandatory fields are filled in
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in "Name" with ""
    And I fill in "Research Centre Name" with ""
    And I fill in "Entity" with ""
    And I fill in "Org. L1 Singular" with ""
    And I fill in "Org. L1 Plural" with ""
    And I fill in "Org. L2 Singular" with ""
    And I fill in "Org. L2 Plural" with ""
    And I press "Update"
    Then I should not see "System configuration updated successfully."
    And I should see "Please correct the following before continuing:"
    And I should see "Name can't be blank"
    And I should see "Research centre name can't be blank"
    And I should see "Entity can't be blank"
    And I should see "Level1 can't be blank"
    And I should see "Level1 plural can't be blank"
    And I should see "Level2 can't be blank"
    And I should see "Level2 plural can't be blank"

  Scenario: Check edited changes are kept after update
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in the following:
      | Local System Name    | Hello |
      | Research Centre Name | World |
      | Entity               | !     |
    And I press "Update"
    And I should be on the system config page
    Then I should see details displayed
      | Local System Name    | Hello                                         |
      | Research Centre Name | World                                         |
      | Overarching Entity   | !                                             |
      | Address              | Locked Bag 1797, Penrith NSW, 2751, Australia |
      | Telephone Numbers    | +61 2 4570 1125                               |
      | Email                | hieinfo@lists.uws.edu.au                      |
      | Description          |                                               |
      | URLs                 | http://www.uws.edu.au/hie                     |

# EYETRACKER-95

  Scenario: Check that the System Name is visible when logged out
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in "Name" with "Hello world"
    And I press "Update"
    And I follow "Sign out"
    Then I should see "Hello world"

# EYETRACKER-95

  Scenario: Check that the footer contains Intersect Australia and the system name
    When I am on the new user session page
    Then I should see "Developed by Intersect Australia Ltd. Powered by HIEv Version:"
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in "Name" with "Hi World"
    And I press "Update"
    Then I should see "Developed by Intersect Australia Ltd. Powered by HIEv Version:"
    When I follow "Sign out"
    Then I should see "Developed by Intersect Australia Ltd. Powered by HIEv Version:"

# EYETRACKER-101

  Scenario: Check a long level 2 name is truncated with ellipsis on white button
    Given I am logged in as "georgina@intersect.org.au"
    And I have facility "Facility0" with code "f0"
    And I am on the edit system config page
    When I fill in "Org. L2 Singular" with "long_name_of_20_char"
    And I press "Update"
    And I am on the facilities page
    And I follow the view link for facility "Facility0"
    Then I should see "New long_na..."

# EYETRACKER-87

  Scenario: Check level 2 Parameters is initially enabled
    Given I am logged in as "georgina@intersect.org.au"
    And I have facility "Facility0" with code "f0"
    And I have experiment "Experiment 1" which belongs to facility "f0"
    And I am on the system config page
    Then I should see "L2 Parameters:Enabled"
    When I am on the edit system config page
    Then the "L2 Parameters" checkbox should be checked
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I follow the view link for experiment "Experiment 1"
    Then I should see "Parameters"
    And I should see "New Parameter"

# EYETRACKER-87

  Scenario: Disabling level 2 Parameters is saved on update
    Given I am logged in as "georgina@intersect.org.au"
    And I have facility "Facility0" with code "f0"
    And I have experiment "Experiment 1" which belongs to facility "f0"
    When I am on the edit system config page
    And I uncheck "L2 Parameters"
    And I press "Update"
    When I should be on the system config page
    When I am on the edit system config page
    Then the "L2 Parameters" checkbox should not be checked
    When I am on the system config page
    Then I should see field "L2 Parameters" with value "Disabled"
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I follow the view link for experiment "Experiment 1"
    Then I should not see "Parameters"
    And I should not see "New Parameter"


# EYETRACKER-138

  Scenario: Saving invalid regex
    Given I am logged in as "georgina@intersect.org.au"
    And I am on the edit system config page
    When I fill in "Auto OCR Regular Expression" with "(unmatched"
    When I fill in "Auto Speech Recognition Regular Expression" with "+w"
    And I press "Update"
    And I should see "Auto OCR Regular Expression: end pattern with unmatched parenthesis: /(unmatched/"
    And I should see "Auto Speech Recognition Regular Expression: target of repeat operator is not specified: /+w/"
