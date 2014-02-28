Feature: Create and manage file access control groups
  In order to restrict access and download to the metadata of files in the system to certain users
  As an administrator
  I want to create and manage file access control groups

  Background:
    Given I have users
      | email                       | first_name | last_name |
      | admin@intersect.org.au      | Admin      | Guy       |
      | cindy@intersect.org.au      | Cindy      | Wang      |
      | researcher@intersect.org.au | Researcher | Man       |
    And I have the usual roles
    And "admin@intersect.org.au" has role "Administrator"
    And "cindy@intersect.org.au" has role "Researcher"

  Scenario: View access control groups as non-admin
    Given I am logged in as "cindy@intersect.org.au"
    When I am on the access groups page
    Then I should see "You are not authorized to access this page."

  Scenario: View access control groups as admin, with no groups in the DB
    Given I am logged in as "admin@intersect.org.au"
    When I am on the access groups page
    Then I should see "Access Groups"
    And I should see "New Access Group"
    And I should see "There are no access groups to display"

  Scenario: View access control groups as admin
    Given I have access groups
      | primary_user           |  created_at       |
      | cindy@intersect.org.au | 26/02/2014 14:18  |
    And I am logged in as "admin@intersect.org.au"
    When I am on the access groups page
    Then I should see "New Access Group"
    And I should see "Name Status Creation Date Primary User Description Edit Status"
    And I should see "name-1 Active 26/02/2014 02:18PM Cindy Wang Deactivate"

  Scenario: List access control groups sorted in alphabetical order on name
    Given I have access groups
      | name   | status | primary_user                | created_at       | description |
      | Durian | false  | cindy@intersect.org.au      | 26/02/2014 14:33 | 4th         |
      | Citrus | true   | admin@intersect.org.au      | 26/02/2014 14:33 | 3rd         |
      | Apple  | false  | researcher@intersect.org.au | 26/02/2014 14:33 | 1st         |
      | Banana | true   | cindy@intersect.org.au      | 26/02/2014 14:33 | 2nd         |
    And I am logged in as "admin@intersect.org.au"
    When I am on the access groups page
    Then I should see "access_groups" table with
      | Name   | Status   | Creation Date      | Primary User      | Description | Edit Status |
      | Apple  | Inactive | 26/02/2014 02:33PM | Researcher Man    | 1st         | Activate    |
      | Banana | Active   | 26/02/2014 02:33PM | Cindy Wang        | 2nd         | Deactivate  |
      | Citrus | Active   | 26/02/2014 02:33PM | Admin Guy         | 3rd         | Deactivate  |
      | Durian | Inactive | 26/02/2014 02:33PM | Cindy Wang        | 4th         | Activate    |

  @javascript
  Scenario: Create new access control group
    Given I have access groups
      | primary_user            | created_at        | description |
      | admin@intersect.org.au  | 26/02/2014 14:53  | existing    |
    And I am logged in as "admin@intersect.org.au"
    When I am on the access groups page
    And I click on "New Access Group"
    Then I should be on the new access groups page
    When I fill in the following:
      | Name        | test1                                       |
      | Description | Testing create default access control group |
    And I press "Save Access Group"
    Then I should see "Access group successfully added."
    And I should see details displayed
      | Name          | test1                                       |
      | Status        | Active                                      |
      | Description   | Testing create default access control group |
      | Primary User  | Admin Guy (admin@intersect.org.au)          |
    When I am on the new access groups page
    When I fill in the following:
      | Name        | test2                                         |
      | Description | Testing create different access control group |
    And I uncheck "Active"
    And I select "cindy@intersect.org.au" from the primary user select box
    And I select and add "admin@intersect.org.au" from the other users select box
    And I select and add "researcher@intersect.org.au" from the other users select box
    And I press "Save Access Group"
    Then I should see "Access group successfully added."
    And I should see details displayed
      | Name          | test2                                         |
      | Status        | Inactive                                      |
      | Description   | Testing create different access control group |
      | Primary User  | Cindy Wang (cindy@intersect.org.au)           |
      | Other User 1  | Admin Guy (admin@intersect.org.au)            |
      | Other User 2  | Researcher Man (researcher@intersect.org.au)  |


