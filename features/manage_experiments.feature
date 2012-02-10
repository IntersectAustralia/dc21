Feature: Manage experiment metadata
  In order to make data more useful to others
  As a researcher
  I want to manage metadata about experiments

  Background:
    Given I am logged in as "georgina@intersect.org.au"

  Scenario: View the list of experiments
    Given I have experiments
      | name             | description    | start_date | end_date   | subject |
      | Tree Chambers 01 | Whatever       | 2012-01-15 | 2013-01-01 | Trees   |
      | Weather Station  | Blah Blah Blah | 2011-10-30 |            | Rain    |
    When I am on the experiments page
    Then I should see "experiments" table with
      | Name             | Start date | End date   | Subject |
      | Tree Chambers 01 | 2012-01-15 | 2013-01-01 | Trees   |
      | Weather Station  | 2011-10-30 |            | Rain    |

  Scenario: View the list when there's nothing to show
    When I am on the experiments page
    Then I should see "There are no experiments to display"

  Scenario: Must be logged in to view the experiments list
    Then users should be required to login on the experiments page

