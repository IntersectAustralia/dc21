Feature: Column Mappings
  As a user
  I want to view a list of column mappings and be able to add/edit/delete them

  Background:
    Given I am logged in as "admin@intersect.org.au"

  Scenario: View the list
    Given I have column mappings
      | name    | code |
      | Sample  | smp  |
      | Average | avg  |
      | Count   | no.  |
    When I am on the column mappings page
    Then I should see "column_mappings" table with
      | Name    | Code |
      | Average | avg  |
      | Count   | no.  |
      | Sample  | smp  |

  Scenario: View the list when there's nothing to show
    When I am on the column mappings page
    Then I should see "No column mappings to display."

  Scenario: Must be logged in to view the list
    Then users should be required to login on the column mappings page

  Scenario: Delete a column mapping
    Given I have column mappings
      | name   | code |
      | Sample | smp  |
    When I am on the column mappings page
    And I follow "delete" for "Sample"
    Then I should see "No column mappings to display."

  Scenario: Delete multiple column mappings
    Given I have column mappings
      | name    | code |
      | Sample  | smp  |
      | Count   | no.  |
      | Average | avg  |
    When I am on the column mappings page
    And I follow "delete" for "Sample"
    And I follow "delete" for "Average"
    Then I should see "column_mappings" table with
      | Name  | Code |
      | Count | no.  |

  Scenario: Add valid column mappings
    Given I am on the column mappings page
    And I follow "Add Mapping"
    And I fill in the following:
      | column_mappings_0_code | rainMM |
      | column_mappings_1_code | pTemp  |
    And I select "Rainfall" from "column_mappings_0_name"
    And I select "Temperature" from "column_mappings_1_name"
    And I press "Submit Column Mappings"
    Then I should see "Column mappings successfully added"
    And I should see "column_mappings" table with
      | Name        | Code   |
      | Rainfall    | rainMM |
      | Temperature | pTemp  |

  Scenario: Add invalid column mappings
    Given I am on the column mappings page
    And I follow "Add Mapping"
    And I fill in the following:
      | column_mappings_0_code |       |
      | column_mappings_1_code | pTemp |
    And I select "Rainfall" from "column_mappings_0_name"
    And I press "Submit Column Mappings"
    Then I should see "Name can't be blank"
    And I should see "Code can't be blank"

  Scenario: Add blank column mappings
    Given I am on the column mappings page
    And I follow "Add Mapping"
    And I press "Submit Column Mappings"
    Then I should see "No column mapping information provided"


  Scenario: Add Mapping on different lines
    Given I am on the column mappings page
    And I follow "Add Mapping"
    And I fill in the following:
      | column_mappings_1_code | rainMM |
      | column_mappings_4_code | pTemp  |
    And I select "Rainfall" from "column_mappings_1_name"
    And I select "Temperature" from "column_mappings_4_name"
    And I press "Submit Column Mappings"
    Then I should see "Column mappings successfully added"
    And I should see "column_mappings" table with
      | Name        | Code   |
      | Rainfall    | rainMM |
      | Temperature | pTemp  |

  Scenario: Add column mapping which already exists
    Given I have column mappings
      | name   | code |
      | Sample | smp  |
    When I am on the column mappings page
    And I follow "Add Mapping"
    And I fill in the following:
      | column_mappings_1_code | smp |
    And I select "Sample" from "column_mappings_1_name"
    And I press "Submit Column Mappings"
    Then I should see "Code has already been taken"

  Scenario: Add two column mappings with same code at same time
    Given I am on the column mappings page
    And I follow "Add Mapping"
    And I fill in the following:
      | column_mappings_2_code | rainMM |
      | column_mappings_3_code | rainMM |
    And I select "Rainfall" from "column_mappings_2_name"
    And I select "Temperature" from "column_mappings_3_name"
    And I press "Submit Column Mappings"
    Then I should see "Can't add column mappings with the same code"

  Scenario: Pressing cancel on add screen redirects to view column mappings page
    Given I am on the column mappings page
    And I follow "Add Mapping"
    And I follow "Cancel"
    Then I should be on the column mappings page





