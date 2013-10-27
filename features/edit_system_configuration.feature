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
    And I fill in "Org. L1 Plural" with ""
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
    Then I should see the following:
      | Local System Name    | Hello |
      | Research Centre Name | World |
      | Entity               | !     |
    And I am on the system config page
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

  # EYETRACKER-101
  Scenario: Check a long level 2 name is truncated with ellipsis on white button
    Given I am logged in as "georgina@intersect.org.au"
    And I have facilities
      | name      | code |
      | Facility0 | f0   |
    And I am on the edit system config page
    When I fill in "Org. L2 Singular" with "long_name_of_20_char"
    And I press "Update"
    And I am on the facilities page
    And I follow the view link for facility "Facility0"
    Then I should see "New long_na..."