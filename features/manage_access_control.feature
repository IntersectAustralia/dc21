Feature: Create and manage file access control groups
  In order to restrict access and download to the metadata of files in the system to certain users
  As an administrator
  I want to create and manage file access control groups

  Background:
    Given I have users
      | email                         | first_name | last_name |
      | cindy@intersect.org.au        | Cindy      | Wang      |
      | researcher@intersect.org.au   | Researcher | Man       |
      | admin@intersect.org.au        | Admin      | Guy       |
      | dev@intersect.org.au          | Dev        | Dude      |
    And I have the usual roles
    And "admin@intersect.org.au" has role "Administrator"
    And "cindy@intersect.org.au" has role "Institutional User"
    And "researcher@intersect.org.au" has role "Institutional User"
    And "dev@intersect.org.au" has role "Administrator"

  Scenario: View access control groups as non-admin
    Given I am logged in as "cindy@intersect.org.au"
    When I am on the list access groups page
    Then I should see "You are not authorized to access this page."

  Scenario: View access control groups as admin, with no groups in the DB
    Given I am logged in as "admin@intersect.org.au"
    When I am on the list access groups page
    Then I should see "Access Groups"
    And I should see link "New Access Group"
    And I should see "There are no access groups to display"

  Scenario: View access control groups as admin
    Given I have access groups
      | name    | primary_user                |  created_at       | status |
      | group-2 | cindy@intersect.org.au      | 26/02/2014 14:18  | true   |
      | group-1 | researcher@intersect.org.au | 03/03/2014 16:32  | false  |
      | group-c | admin@intersect.org.au      | 02/01/2014 00:00  | true   |
    And I am logged in as "admin@intersect.org.au"
    When I am on the list access groups page
    Then I should see "New Access Group"
    And I should see "access_groups" table with
      | Name    | Status   | Creation Date      | Primary User      | Description | Edit Status |
      | group-1 | Inactive | 03/03/2014 04:32PM | Researcher Man    |             | Activate    |
      | group-2 | Active   | 26/02/2014 02:18PM | Cindy Wang        |             | Deactivate  |
      | group-c | Active   | 02/01/2014 12:00AM | Admin Guy         |             | Deactivate  |
    When I click on "Activate"
    Then I should see "access_groups" table with
      | Name    | Status   | Creation Date      | Primary User      | Description | Edit Status |
      | group-1 | Active   | 03/03/2014 04:32PM | Researcher Man    |             | Deactivate  |
      | group-2 | Active   | 26/02/2014 02:18PM | Cindy Wang        |             | Deactivate  |
      | group-c | Active   | 02/01/2014 12:00AM | Admin Guy         |             | Deactivate  |

  Scenario: Activate and deactivate an access group
    Given I have access groups
      | primary_user            | created_at        |
      | cindy@intersect.org.au  | 03/03/2014 18:10  |
    And I am logged in as "admin@intersect.org.au"
    When I am on the list access groups page
    Then I should see "access_groups" table with
      | Name    | Status   | Creation Date      | Primary User      | Description | Edit Status |
      | name-1  | Active   | 03/03/2014 06:10PM | Cindy Wang        |             | Deactivate  |
    When I click on "Deactivate"
    Then I should see "access_groups" table with
      | Name    | Status   | Creation Date      | Primary User      | Description | Edit Status |
      | name-1  | Inactive | 03/03/2014 06:10PM | Cindy Wang        |             | Activate    |
    When I click on "Activate"
    Then I should see "access_groups" table with
      | Name    | Status   | Creation Date      | Primary User      | Description | Edit Status |
      | name-1  | Active   | 03/03/2014 06:10PM | Cindy Wang        |             | Deactivate  |
    When I click on "name-1"
    Then I should see link "Deactivate"
    When I click on "Deactivate"
    Then I should see "access_groups" table with
      | Name    | Status   | Creation Date      | Primary User      | Description | Edit Status |
      | name-1  | Inactive | 03/03/2014 06:10PM | Cindy Wang        |             | Activate    |
    When I click on "name-1"
    Then I should see link "Activate"
    When I click on "Activate"
    Then I should see "access_groups" table with
      | Name    | Status   | Creation Date      | Primary User      | Description | Edit Status |
      | name-1  | Active   | 03/03/2014 06:10PM | Cindy Wang        |             | Deactivate  |

  Scenario: List access control groups sorted in alphabetical order on name
    Given I have access groups
      | name   | status | primary_user                | created_at       | description |
      | Durian | false  | cindy@intersect.org.au      | 26/02/2014 14:33 | 4th         |
      | Citrus | true   | admin@intersect.org.au      | 26/02/2014 14:33 | 3rd         |
      | Apple  | false  | researcher@intersect.org.au | 26/02/2014 14:33 | 1st         |
      | Banana | true   | cindy@intersect.org.au      | 26/02/2014 14:33 | 2nd         |
    And I am logged in as "admin@intersect.org.au"
    When I am on the list access groups page
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
    When I am on the list access groups page
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
      | Other Users   | There are no other users in this Access Control Group. |
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
      | Other Users   |                                               |
    And I should see "access_group_users" table with
      | First Name | Last Name | Email                        | Role               | Status |
      | Admin      | Guy       | admin@intersect.org.au       | Administrator      | Active |
      | Researcher | Man       | researcher@intersect.org.au  | Institutional User | Active |

  @javascript
  Scenario: Drill down on access group name from the list of access groups
    Given I have access groups
      | name    | primary_user                |  created_at       | status | description                                              |
      | group-2 | cindy@intersect.org.au      | 26/02/2014 14:18  | true   | test editing access control group                        |
      | group-1 | researcher@intersect.org.au | 03/03/2014 16:32  | false  | test drill down on group name from list of access groups |
    And I am logged in as "admin@intersect.org.au"
    When I am on the list access groups page
    And I click on "group-1"
    Then I should see "Access group details for group-1"
    And I should see details displayed
      | Name         | group-1                                                  |
      | Status       | Inactive                                                 |
      | Description  | test drill down on group name from list of access groups |
      | Date Created | 03/03/2014 04:32PM                                       |
      | Primary User | Researcher Man (researcher@intersect.org.au)             |
      | Other Users  | There are no other users in this Access Control Group.   |
    And I should see link "Back"
    And I should see link "Edit Access Control Group"
    And I should see link "Activate"
    When I click on "Back"
    Then I should be on the list access groups page
    When I click on "group-2"
    And I click on "Edit Access Control Group"
    Then I should see "Admin / Access Control Groups / Edit"
    And I should see "Edit Access Control Group"
    And I fill in "Name" with "Group-2"
    And I uncheck "Active"
    And I fill in "Description" with "edited access control group"
    And I select "admin@intersect.org.au" from the primary user select box
    And I select and add "cindy@intersect.org.au" from the other users select box
    And I select and add "researcher@intersect.org.au" from the other users select box
    And I press "Update"
    Then I should see "Access group successfully updated."
    And I should see "Admin / Access Groups / Group-2"
    And I should see "Access group details for Group-2"
    And I should see details displayed
      | Name         | Group-2                            |
      | Status       | Inactive                           |
      | Description  | edited access control group        |
      | Date Created | 26/02/2014 02:18PM                 |
      | Primary User | Admin Guy (admin@intersect.org.au) |
      | Other Users  |                                    |
    And I should see "access_group_users" table with
      | First Name | Last Name | Email                        | Role               | Status |
      | Cindy      | Wang      | cindy@intersect.org.au       | Institutional User | Active |
      | Researcher | Man       | researcher@intersect.org.au  | Institutional User | Active |

  @javascript
  Scenario: Display and edit access groups a user belongs to on the user's details page
    Given I have access groups
      | name  | created_at       | primary_user                |
      | one   | 04/03/2014 15:43 | researcher@intersect.org.au |
      | two   | 04/03/2014 12:16 | admin@intersect.org.au      |
      | three | 04/03/2014 09:20 | cindy@intersect.org.au      |
      | four  | 01/01/2014 00:00 | admin@intersect.org.au      |
    And I am logged in as "admin@intersect.org.au"
    When I am on the edit access group page for 'one'
    And I add the following users:
      | email |
      | dev@intersect.org.au |
      | cindy@intersect.org.au        |
    When I am on the edit access group page for 'two'
    And I add the following users:
      | email |
      | researcher@intersect.org.au |
      | cindy@intersect.org.au      |
      | dev@intersect.org.au |
    When I am on the edit access group page for 'three'
    And I add the following users:
      | email |
      | admin@intersect.org.au |
      | researcher@intersect.org.au |
      | dev@intersect.org.au |
    When I am on the list users page
    And I click on "dev@intersect.org.au"
    Then I should be on the user details page for dev@intersect.org.au
    And I should see button "Add Access Group"
    And I should see "access_groups" table with
      | Name  | Status | Creation Date       | Primary User   | Description | Remove |
      | one   | Active | 04/03/2014 03:43PM  | Researcher Man |             |        |
      | three | Active | 04/03/2014 09:20AM  | Cindy Wang     |             |        |
      | two   | Active | 04/03/2014 12:16PM  | Admin Guy      |             |        |
    When I select and add "four" from the user access groups box
    Then I should see "access_groups" table with
      | Name  | Status | Creation Date       | Primary User   | Description | Remove |
      | four  | Active | 01/01/2014 12:00AM  | Admin Guy      |             |        |
      | one   | Active | 04/03/2014 03:43PM  | Researcher Man |             |        |
      | three | Active | 04/03/2014 09:20AM  | Cindy Wang     |             |        |
      | two   | Active | 04/03/2014 12:16PM  | Admin Guy      |             |        |
    And I follow "delete" for access group "three"
    Then I should be on the user details page for dev@intersect.org.au
    And I should see "access_groups" table with
      | Name  | Status | Creation Date       | Primary User   | Description | Remove |
      | four  | Active | 01/01/2014 12:00AM  | Admin Guy      |             |        |
      | one   | Active | 04/03/2014 03:43PM  | Researcher Man |             |        |
      | two   | Active | 04/03/2014 12:16PM  | Admin Guy      |             |        |