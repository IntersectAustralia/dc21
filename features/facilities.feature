Feature: View the list of facilities
  As a user
  I want to view a list of facilities and be able to add/edit and view them

  Background:
    Given I am logged in as "admin@intersect.org.au"

  Scenario: View the list
    Given I have facilities
      | name      | code |
      | Facility0 | f0   |
      | Facility1 | f1   |
    When I am on the facilities page
    Then I should see "facilities" table with
      | Name      | Code |
      | Facility0 | f0   |
      | Facility1 | f1   |

  Scenario: Facilities list should be ordered by name
    Given I have facilities
      | name      | code |
      | Facility2 | f2   |
      | Facility1 | f1   |
      | Facility4 | f4   |
      | Facility0 | f0   |
      | Facility3 | f3   |
    When I am on the facilities page
    Then I should see "facilities" table with
      | Name      | Code |
      | Facility0 | f0   |
      | Facility1 | f1   |
      | Facility2 | f2   |
      | Facility3 | f3   |
      | Facility4 | f4   |

  Scenario: View the list when there's nothing to show
    When I am on the facilities page
    Then I should see "There are no facilities to display"

  Scenario: Must be logged in to view the facilities list
    Then users should be required to login on the facilities page


  Scenario: View a facility
    Given I have facilities
      | name      | code | description | a_lat      | a_long    | b_lat      | b_long    |
      | Facility0 | f0   | abcdefg     | -33.856557 | 151.21460 | -33.856657 | 151.21550 |
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    Then I should see details displayed
      | Name                | Facility0             |
      | Code                | f0                    |
      | Description         | abcdefg               |
      | Top Left Corner     | -33.856557 , 151.2146 |
      | Bottom Right Corner | -33.856657 , 151.2155 |

  Scenario: Navigate back to the list of facilities
    Given I have facilities
      | name      | code |
      | Facility0 | f0   |
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I follow "Back"
    Then I should be on the facilities page

  @javascript
  Scenario: Create a new facility
    Given I am on the facilities page
    And I have users
      | email                  | first_name | last_name |
      | one@intersect.org.au   | User       | One       |
      | two@intersect.org.au   | User       | Two       |
      | three@intersect.org.au | User       | Three     |

    And I follow "New Facility"
    When I fill in the following:
      | Name                     | Facility0 |
      | Code                     | f0        |
      | Description              | blah      |
      | Latitude                 | -10.1     |
      | Longitude                | 20.2      |
      | Latitude (bottom right)  | -30.3     |
      | Longitude (bottom right) | 40.4      |
    And I select "two@intersect.org.au" from the primary select box
    And I select and add "one@intersect.org.au" from the other contacts select box
    And I select and add "three@intersect.org.au" from the other contacts select box
    And I press "Save Facility"
    Then I should see "Facility successfully added"
    And I should see details displayed
      | Name                | Facility0                           |
      | Code                | f0                                  |
      | Description         | blah                                |
      | Top Left Corner     | -10.1 , 20.2                        |
      | Bottom Right Corner | -30.3 , 40.4                        |
      | Primary Contact     | User Two (two@intersect.org.au)     |
      | Other Contact 1     | User One (one@intersect.org.au)     |
      | Other Contact 2     | User Three (three@intersect.org.au) |

  @javascript
  Scenario: Editing a facility should correctly show and update contacts
    Given I am on the facilities page
    And I have users
      | email                  | first_name | last_name |
      | one@intersect.org.au   | User       | One       |
      | two@intersect.org.au   | User       | Two       |
      | three@intersect.org.au | User       | Three     |
      | four@intersect.org.au  | User       | Four      |

    And I follow "New Facility"
    When I fill in the following:
      | Name | Facility0 |
      | Code | f0        |
    And I select "two@intersect.org.au" from the primary select box
    And I select and add "one@intersect.org.au" from the other contacts select box
    And I select and add "three@intersect.org.au" from the other contacts select box
    And I press "Save Facility"
    And I follow "Edit Facility"
    And I select "four@intersect.org.au" from the primary select box
    And I press "Update"
    Then I should see "Facility successfully updated"
    And I should see details displayed
      | Primary Contact | User Four (four@intersect.org.au)   |
      | Other Contact 1 | User One (one@intersect.org.au)     |
      | Other Contact 2 | User Three (three@intersect.org.au) |

  Scenario: Create a new facility with invalid details
    Given I am on the facilities page
    And I follow "New Facility"
    When I fill in the following:
      | Name |  |
      | Code |  |
    And I press "Save Facility"
    Then I should see "Name can't be blank"
    And I should see "Code can't be blank"

  Scenario: Create a duplicate facility
    Given I have facilities
      | name      | code |
      | Facility0 | f0   |
    When I am on the facilities page
    And I follow "New Facility"
    When I fill in the following:
      | Name | Facility0 |
      | Code | f0        |
    And I press "Save Facility"
    Then I should see "Name has already been taken"
    Then I should see "Code has already been taken"

  Scenario: Navigate back to the list of facilities from create screen
    Given I am on the facilities page
    And I follow "New Facility"
    And I follow "Cancel"
    Then I should be on the facilities page

  Scenario: Edit the details of a facility
    Given I have facilities
      | name      | code |
      | Facility0 | f0   |
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I follow "Edit Facility"
    And I fill in the following:
      | Name | Facility1 |
      | Code | fac1      |
    And I press "Update"
    Then I should see "Facility successfully updated."
    And I should see details displayed
      | Name | Facility1 |
      | Code | fac1      |

  Scenario: Edit the details of a facility to something invalid
    Given I have facilities
      | name      | code |
      | Facility0 | f0   |
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I follow "Edit Facility"
    And I fill in the following:
      | Code |  |
    And I press "Update"
    Then I should see "Code can't be blank"

  Scenario: Edit the details of a facility to become a duplicate
    Given I have facilities
      | name      | code |
      | Facility0 | f0   |
      | Facility1 | f1   |
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I follow "Edit Facility"
    And I fill in the following:
      | Name | Facility1 |
      | Code | f1        |
    And I press "Update"
    Then I should see "Name has already been taken"
    And I should see "Code has already been taken"

  Scenario: Cancelling the edit of a facility
    Given I have facilities
      | name      | code |
      | Facility0 | f0   |
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I follow "Edit Facility"
    And I fill in the following:
      | Name | Facility1 |
      | Code | f1        |
    And I follow "Cancel"
    Then I should see details displayed
      | Name | Facility0 |
      | Code | f0        |

  Scenario: Navigate back to the list of facilities from edit screen
    Given I have facilities
      | name      | code |
      | Facility0 | f0   |
    When I am on the facilities page
    And I follow the view link for facility "Facility0"
    And I follow "Edit Facility"
    And I follow "Cancel"
    Then I should see details displayed
      | Name | Facility0 |
      | Code | f0        |

