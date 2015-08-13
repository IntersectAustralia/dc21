Feature: Manage experiment metadata
  In order to make data more useful to others
  As a researcher
  I want to manage metadata about experiments

  Background:
    Given I am logged in as "admin@intersect.org.au"
    And I have facilities
      | name                |
      | ROS Weather Station |
      | Tree Chambers       |
    And I have experiments
      | name             | description    | start_date | end_date   | subject | facility            | parent          | access_rights                                    |
      | Weather Station  | Blah Blah Blah | 2011-10-30 |            | Rain    | ROS Weather Station |                 | http://creativecommons.org/licenses/by-sa/4.0    |
      | Tree Chamber 02  | Whatever 2     | 2012-01-01 | 2013-01-31 | Trees   | Tree Chambers       |                 | http://creativecommons.org/licenses/by-sa/4.0    |
      | Tree Chamber 01  | Whatever       | 2012-01-15 | 2013-01-01 | Trees   | Tree Chambers       |                 | http://creativecommons.org/licenses/by-sa/4.0    |
      | Tree Chamber 01A | Another        | 2012-01-15 |            | Trees   | Tree Chambers       | Tree Chamber 01 | http://creativecommons.org/licenses/by-nc-nd/4.0 |

  Scenario: View the list of experiments under a facility
    When I am on the view facility page for 'Tree Chambers'
    Then I should see "experiments" table with
      | Name             | Parent                       | Description |
      | Tree Chamber 01  | Facility - Tree Chambers     | Whatever    |
      | Tree Chamber 01A | Experiment - Tree Chamber 01 | Another     |
      | Tree Chamber 02  | Facility - Tree Chambers     | Whatever 2  |

  Scenario: View the list when there's nothing to show
    Given I have no experiments
    When I am on the view facility page for 'Tree Chambers'
    Then I should see "There are no experiments to display"

  Scenario: Must be logged in to view the details, create, edit pages
    Then users should be required to login on the view experiment page for 'Weather Station'
    Then users should be required to login on the edit experiment page for 'Weather Station'
    Then users should be required to login on the new experiment page for facility 'Tree Chambers'

  Scenario: View an experiment
    Given I am on the view facility page for 'Tree Chambers'
    And I follow the view link for experiment "Tree Chamber 01"
    Then I should see details displayed
      | Name          | Tree Chamber 01                   |
      | Description   | Whatever                          |
      | Start date    | 2012-01-15                        |
      | End date      | 2013-01-01                        |
      | Subject       | Trees                             |
      | Access rights | CC BY-SA: Attribution-Share Alike |
    When I follow "Back"
    Then I should be on the view facility page for 'Tree Chambers'

  Scenario: Create a new experiment with facility as the parent
    Given I am on the view facility page for 'Tree Chambers'
    When I follow "New Experiment"
    Then the "Parent" select should contain
      | Facility - Tree Chambers      |
      | Experiment - Tree Chamber 01  |
      | Experiment - Tree Chamber 01A |
      | Experiment - Tree Chamber 02  |
    And nothing should be selected in the "Parent" select
    And I fill in the following:
      | Name          | My Experiment                     |
      | Description   | Some description blah blah        |
      | Start date    | 2011-12-12                        |
      | End date      | 2012-01-31                        |
      | Subject       | Trees                             |
      | Access rights | CC BY-SA: Attribution-Share Alike |
    And I press "Save Experiment"
    Then I should see "The experiment was saved successfully"
    And I should see details displayed
      | Name          | My Experiment                     |
      | Parent        | Facility - Tree Chambers          |
      | Description   | Some description blah blah        |
      | Start date    | 2011-12-12                        |
      | End date      | 2012-01-31                        |
      | Subject       | Trees                             |
      | Access rights | CC BY-SA: Attribution-Share Alike |

  Scenario: Create a new experiment with another experiment as the parent
    Given I am on the view facility page for 'Tree Chambers'
    When I follow "New Experiment"
    And I fill in the following:
      | Name          | My Experiment                     |
      | Description   | Some description blah blah        |
      | Start date    | 2011-12-12                        |
      | End date      | 2012-01-31                        |
      | Subject       | Trees                             |
      | Parent        | Experiment - Tree Chamber 02      |
      | Access rights | CC BY-SA: Attribution-Share Alike |
    And I press "Save Experiment"
    Then I should see "The experiment was saved successfully"
    And I should see details displayed
      | Name          | My Experiment                     |
      | Parent        | Experiment - Tree Chamber 02      |
      | Description   | Some description blah blah        |
      | Start date    | 2011-12-12                        |
      | End date      | 2012-01-31                        |
      | Subject       | Trees                             |
      | Access rights | CC BY-SA: Attribution-Share Alike |

  Scenario: Create a new experiment with a validation error
    Given I am on the view facility page for 'Tree Chambers'
    When I follow "New Experiment"
    And I fill in the following:
      | Name        |                            |
      | Description | Some description blah blah |
      | Start date  | 2011-12-12                 |
      | End date    | 2012-01-31                 |
      | Subject     | Trees                      |
    And I press "Save Experiment"
    Then I should see "Name can't be blank"
    Then I should see "Access rights can't be blank"

  Scenario: Cancel out of create
    Given I am on the view facility page for 'Tree Chambers'
    When I follow "New Experiment"
    And I follow "Cancel"
    Then I should be on the view facility page for 'Tree Chambers'

  Scenario: Edit an experiment
    Given I edit experiment "Tree Chamber 01"
    Then the "Parent" select should contain
      | Facility - Tree Chambers      |
      | Experiment - Tree Chamber 01A |
      | Experiment - Tree Chamber 02  |
    And nothing should be selected in the "Parent" select
    When I fill in the following:
      | Name          | My Experiment                             |
      | Parent        | Experiment - Tree Chamber 02              |
      | Description   | Some description blah blah                |
      | Start date    | 2011-12-12                                |
      | End date      | 2012-01-31                                |
      | Subject       | Trees                                     |
      | Access rights | CC BY-ND: Attribution-No Derivative Works |
    And I press "Save Experiment"
    Then I should see "The experiment was saved successfully"
    And I should see details displayed
      | Name          | My Experiment                             |
      | Parent        | Experiment - Tree Chamber 02              |
      | Description   | Some description blah blah                |
      | Start date    | 2011-12-12                                |
      | End date      | 2012-01-31                                |
      | Subject       | Trees                                     |
      | Access rights | CC BY-ND: Attribution-No Derivative Works |

  Scenario: Edit an experiment that has an experiment as the parent
    Given the experiment "Tree Chamber 01" has parent "Tree Chamber 02"
    When I edit experiment "Tree Chamber 01"
    Then the "Parent" select should contain
      | Facility - Tree Chambers      |
      | Experiment - Tree Chamber 01A |
      | Experiment - Tree Chamber 02  |
    And "Experiment - Tree Chamber 02" should be selected in the "Parent" select
    When I fill in the following:
      | Name          | My Experiment                             |
      | Parent        | Facility - Tree Chambers                  |
      | Description   | Some description blah blah                |
      | Start date    | 2011-12-12                                |
      | End date      | 2012-01-31                                |
      | Subject       | Trees                                     |
      | Access rights | CC BY-ND: Attribution-No Derivative Works |
    And I press "Save Experiment"
    Then I should see "The experiment was saved successfully"
    And I should see details displayed
      | Name          | My Experiment                             |
      | Parent        | Facility - Tree Chambers                  |
      | Description   | Some description blah blah                |
      | Start date    | 2011-12-12                                |
      | End date      | 2012-01-31                                |
      | Subject       | Trees                                     |
      | Access rights | CC BY-ND: Attribution-No Derivative Works |

  Scenario: Edit with a validation error
    Given I edit experiment "Weather Station"
    And I fill in the following:
      | Name        |                            |
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

  Scenario: Date format is visible on the New Experiment page
    Given I am on the view facility page for 'Tree Chambers'
    When I follow "New Experiment"
    Then I should see "yyyy-mm-dd"
