Feature: Manage experiment metadata
  In order to make data more useful to others
  As a researcher
  I want to manage metadata about experiments

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have facilities
      | name          |
      | ROS Weather Station |
    And I have experiments
      | name            | description    | start_date | end_date | subject | facility            | parent |
      | Weather Station | Blah Blah Blah | 2011-10-30 |          | Rain    | ROS Weather Station |        |

  @javascript
  Scenario: Selecting FOR codes while creating an experiment
    Given I have filled in the basic fields on the new experiment page under facility "ROS Weather Station"
    Then the "FOR Code" select should contain
      | Please select               |
      | 01 - MATHEMATICAL SCIENCES  |
      | 02 - PHYSICAL SCIENCES      |
      | 03 - CHEMICAL SCIENCES      |
      | 04 - EARTH SCIENCES         |
      | 05 - ENVIRONMENTAL SCIENCES |
      | 06 - BIOLOGICAL SCIENCES    |
  #TODO: second, third level codes
    When I add for code "02 - PHYSICAL SCIENCES"
    And I add for code "05 - ENVIRONMENTAL SCIENCES"
    And I press "Save Experiment"
    Then I should see for codes
      | 02 - PHYSICAL SCIENCES      |
      | 05 - ENVIRONMENTAL SCIENCES |

  @javascript
  Scenario: FOR codes chosen so far aren't lost on validation error
    Given I am on the new experiment page for facility 'ROS Weather Station'
  #TODO: second, third level codes
    When I add for code "02 - PHYSICAL SCIENCES"
    And I add for code "05 - ENVIRONMENTAL SCIENCES"
    And I press "Save Experiment"
    Then I should see "Name can't be blank"
    And I should see for codes
      | 02 - PHYSICAL SCIENCES      |
      | 05 - ENVIRONMENTAL SCIENCES |

  @javascript
  Scenario: FOR codes already chosen are retained on edit
    Given experiment "Weather Station" has for code "02 - PHYSICAL SCIENCES"
    When I edit experiment "Weather Station"
    Then I should see for codes
      | 02 - PHYSICAL SCIENCES      |
  #TODO: second, third level codes
    And I add for code "05 - ENVIRONMENTAL SCIENCES"
    And I press "Save Experiment"
    And I should see for codes
      | 02 - PHYSICAL SCIENCES      |
      | 05 - ENVIRONMENTAL SCIENCES |

  @javascript
  Scenario: Additional FOR codes chosen so far aren't lost on validation error during edit
    Given experiment "Weather Station" has for code "02 - PHYSICAL SCIENCES"
    When I edit experiment "Weather Station"
  #TODO: second, third level codes
    And I add for code "05 - ENVIRONMENTAL SCIENCES"
    And I fill in "Name" with ""
    And I press "Save Experiment"
    Then I should see "Name can't be blank"
    And I should see for codes
      | 02 - PHYSICAL SCIENCES      |
      | 05 - ENVIRONMENTAL SCIENCES |

  @javascript
  Scenario: Can delete FOR codes during create
    Given I have filled in the basic fields on the new experiment page under facility "ROS Weather Station"
  #TODO: second, third level codes
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
  #TODO: second, third level codes
    And I add for code "01 - MATHEMATICAL SCIENCES"
    And I add for code "06 - BIOLOGICAL SCIENCES"
    And I delete for code "02 - PHYSICAL SCIENCES"
    And I delete for code "06 - BIOLOGICAL SCIENCES"
    And I press "Save Experiment"
    And I should see for codes
      | 01 - MATHEMATICAL SCIENCES  |
      | 05 - ENVIRONMENTAL SCIENCES |

