Feature: Manage experiment metadata
  In order to make data more useful to others
  As a researcher
  I want to manage metadata about experiments, including the selection of FOR (field of research) codes

  Background:
    Given I am logged in as "admin@intersect.org.au"
    And I have facilities
      | name                |
      | ROS Weather Station |
    And I have experiments
      | name            | facility            |
      | Weather Station | ROS Weather Station |

  @javascript
  Scenario: Second and third level dropdowns populate based on selection in the previous one
    Given I have filled in the basic fields on the new experiment page under facility "ROS Weather Station"
    When I select "03 - CHEMICAL SCIENCES" from "FOR codes"
    And I sleep briefly
    Then the "for_code_level2" select should contain
      | Please select |
      | 0301 - ITEM 1 |
      | 0302 - ITEM 2 |
      | 0303 - ITEM 3 |
      | 0304 - ITEM 4 |
      | 0305 - ITEM 5 |
      | 0306 - ITEM 6 |
      | 0307 - ITEM 7 |
      | 0308 - ITEM 8 |
      | 0309 - ITEM 9 |
    When I select "0302 - ITEM 2" from "for_code_level2"
    And I sleep briefly
    Then the "for_code_level3" select should contain
      | Please select   |
      | 030201 - ITEM 1 |
      | 030202 - ITEM 2 |
      | 030203 - ITEM 3 |
      | 030204 - ITEM 4 |
      | 030205 - ITEM 5 |
      | 030206 - ITEM 6 |
      | 030207 - ITEM 7 |
      | 030208 - ITEM 8 |
      | 030209 - ITEM 9 |
#TODO: behaviour on change / switch to other at the various levels

  @javascript
  Scenario: Selecting FOR codes while creating an experiment
    Given I have filled in the basic fields on the new experiment page under facility "ROS Weather Station"
    And I wait for MINT server
    Then the "FOR codes" select should contain
      | Please select               |
      | 01 - MATHEMATICAL SCIENCES  |
      | 02 - PHYSICAL SCIENCES      |
      | 03 - CHEMICAL SCIENCES      |
      | 04 - EARTH SCIENCES         |
      | 05 - ENVIRONMENTAL SCIENCES |
      | 06 - BIOLOGICAL SCIENCES    |
    When I add for code "02 - PHYSICAL SCIENCES"
    And I wait for MINT server
    And I add for code "05 - ENVIRONMENTAL SCIENCES", "0502 - ITEM 2"
    And I wait for MINT server
    And I add for code "03 - CHEMICAL SCIENCES", "0303 - ITEM 3", "030302 - ITEM 2"
    And I press "Save Experiment"
    Then I should see for codes
      | 02 - PHYSICAL SCIENCES |
      | 030302 - ITEM 2        |
      | 0502 - ITEM 2          |

  @javascript
  Scenario: Blank cannot be added
    Given I have filled in the basic fields on the new experiment page under facility "ROS Weather Station"
    When I follow "Add"
    Then I should see no for codes

  @javascript
  Scenario: FOR codes chosen so far aren't lost on validation error
    Given I am on the new experiment page for facility 'ROS Weather Station'
    And I wait for MINT server
    When I add for code "02 - PHYSICAL SCIENCES"
    And I wait for MINT server
    And I add for code "05 - ENVIRONMENTAL SCIENCES", "0502 - ITEM 2"
    And I wait for MINT server
    And I add for code "03 - CHEMICAL SCIENCES", "0303 - ITEM 3", "030302 - ITEM 2"
    And I press "Save Experiment"
    Then I should see "Name can't be blank"
    And I should see for codes
      | 02 - PHYSICAL SCIENCES |
      | 0502 - ITEM 2          |
      | 030302 - ITEM 2        |

  @javascript
  Scenario: FOR codes already chosen are retained on edit
    Given experiment "Weather Station" has for code "02 - PHYSICAL SCIENCES"
    When I edit experiment "Weather Station"
  # workaround due to javascript lag causing this to fail intermittently
    And I sleep briefly
    Then I should see for codes
      | 02 - PHYSICAL SCIENCES |
    And I add for code "05 - ENVIRONMENTAL SCIENCES"
    And I press "Save Experiment"
    And I should see for codes
      | 02 - PHYSICAL SCIENCES      |
      | 05 - ENVIRONMENTAL SCIENCES |

  @javascript
  Scenario: Added/deleted FOR codes aren't lost on validation error during edit (but are not yet persisted)
    Given experiment "Weather Station" has for code "02 - PHYSICAL SCIENCES"
    And experiment "Weather Station" has for code "05 - ENVIRONMENTAL SCIENCES"
    When I edit experiment "Weather Station"
    And I add for code "01 - MATHEMATICAL SCIENCES"
    And I delete for code "02 - PHYSICAL SCIENCES"
    And I fill in "Name" with ""
    And I press "Save Experiment"
    Then I should see "Name can't be blank"
    And I should see for codes
      | 05 - ENVIRONMENTAL SCIENCES |
      | 01 - MATHEMATICAL SCIENCES  |
  # changes should not be persisted yet
    And experiment "Weather Station" should have for codes
      | 02 - PHYSICAL SCIENCES      |
      | 05 - ENVIRONMENTAL SCIENCES |
  # fix the problem and save
    When I fill in "Name" with "New name"
    And I press "Save Experiment"
    Then I should see for codes
      | 01 - MATHEMATICAL SCIENCES  |
      | 05 - ENVIRONMENTAL SCIENCES |
    And experiment "New name" should have 2 for codes

  @javascript
  Scenario: Can delete FOR codes during create
    Given I have filled in the basic fields on the new experiment page under facility "ROS Weather Station"
    And I wait for MINT server
    When I add for code "02 - PHYSICAL SCIENCES"
    And I add for code "05 - ENVIRONMENTAL SCIENCES"
    And I delete for code "02 - PHYSICAL SCIENCES"
    And I press "Save Experiment"
    Then I should see for codes
      | 05 - ENVIRONMENTAL SCIENCES |

  @javascript
  Scenario: Can delete FOR codes during edit
    Given experiment "Weather Station" has for code "02 - PHYSICAL SCIENCES"
    Given experiment "Weather Station" has for code "05 - ENVIRONMENTAL SCIENCES"
    When I edit experiment "Weather Station"
    And I wait for MINT server
    And I add for code "01 - MATHEMATICAL SCIENCES"
    And I wait for MINT server
    And I add for code "03 - CHEMICAL SCIENCES", "0303 - ITEM 3", "030302 - ITEM 2"
    And I delete for code "02 - PHYSICAL SCIENCES"
    And I delete for code "01 - MATHEMATICAL SCIENCES"
    And I press "Save Experiment"
    And I should see for codes
      | 030302 - ITEM 2             |
      | 05 - ENVIRONMENTAL SCIENCES |
    And experiment "Weather Station" should have 2 for codes

