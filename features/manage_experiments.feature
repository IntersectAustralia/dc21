Feature: Manage experiment metadata
  In order to make data more useful to others
  As a researcher
  I want to manage metadata about experiments

  Background:
    Given I am logged in as "georgina@intersect.org.au"
    And I have experiments
      | name             | description    | start_date | end_date   | subject |
      | Weather Station  | Blah Blah Blah | 2011-10-30 |            | Rain    |
      | Tree Chambers 01 | Whatever       | 2012-01-15 | 2013-01-01 | Trees   |

  Scenario: View the list of experiments
    When I am on the experiments page
    Then I should see "experiments" table with
      | Name             | Start date | End date   | Subject |
      | Tree Chambers 01 | 2012-01-15 | 2013-01-01 | Trees   |
      | Weather Station  | 2011-10-30 |            | Rain    |

  Scenario: View the list when there's nothing to show
    Given I have no experiments
    When I am on the experiments page
    Then I should see "There are no experiments to display"

  Scenario: Must be logged in to view the experiments list, details, create, edit pages
    Then users should be required to login on the experiments page
    Then users should be required to login on the view experiment page for 'Weather Station'
    Then users should be required to login on the edit experiment page for 'Weather Station'
    Then users should be required to login on the new experiment page

  Scenario: View an experiment
    When I am on the experiments page
    And I follow the view link for experiment "Tree Chambers 01"
    Then I should see details displayed
      | Name        | Tree Chambers 01 |
      | Description | Whatever         |
      | Start date  | 2012-01-15       |
      | End date    | 2013-01-01       |
      | Subject     | Trees            |
    When I follow "Back"
    Then I should be on the experiments page

  Scenario: Create a new experiment
    Given I am on the experiments page
    When I follow "New Experiment"
    And I fill in the following:
      | Name        | My Experiment              |
      | Description | Some description blah blah |
      | Start date  | 2011-12-12                 |
      | End date    | 2012-01-31                 |
      | Subject     | Trees                      |
    And I press "Save Experiment"
    Then I should see "The experiment was saved successfully"
    And I should see details displayed
      | Name        | My Experiment              |
      | Description | Some description blah blah |
      | Start date  | 2011-12-12                 |
      | End date    | 2012-01-31                 |
      | Subject     | Trees                      |

  Scenario: Create a new experiment with a validation error
    Given I am on the experiments page
    When I follow "New Experiment"
    And I fill in the following:
      | Name        |                            |
      | Description | Some description blah blah |
      | Start date  | 2011-12-12                 |
      | End date    | 2012-01-31                 |
      | Subject     | Trees                      |
    And I press "Save Experiment"
    Then I should see "Name can't be blank"

  Scenario: Cancel out of create
    Given I am on the experiments page
    And I follow "New Experiment"
    And I follow "Cancel"
    Then I should be on the experiments page

  Scenario: Edit an experiment
    Given I edit experiment "Weather Station"
    And I fill in the following:
      | Name        | My Experiment              |
      | Description | Some description blah blah |
      | Start date  | 2011-12-12                 |
      | End date    | 2012-01-31                 |
      | Subject     | Trees                      |
    And I press "Save Experiment"
    Then I should see "The experiment was saved successfully"
    And I should see details displayed
      | Name        | My Experiment              |
      | Description | Some description blah blah |
      | Start date  | 2011-12-12                 |
      | End date    | 2012-01-31                 |
      | Subject     | Trees                      |

  Scenario: Edit with a validation error
    Given I edit experiment "Weather Station"
    And I fill in the following:
      | Name        |               |
      | Description | Some description blah blah |
      | Start date  | 2011-12-12                 |
      | End date    | 2012-01-31                 |
      | Subject     | Trees                      |
    And I press "Save Experiment"
    Then I should see "Name can't be blank"

  Scenario: Cancel out of editing
    Given I edit experiment "Weather Station"
    And I follow "Cancel"
    Then I should be on the view experiment page for 'Weather Station'

