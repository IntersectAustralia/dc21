Feature: Download multiple files
  In order to get hold of the data I'm interested in
  As a user
  I want to download multiple files from the explore data page

  Background:
    Given I have the usual roles
    And I have a user "admin@intersect.org.au" with role "Administrator"
    And I have a user "researcher@intersect.org.au" with role "Institutional User"
    And I have a user "external@intersect.org.au" with role "Non-Institutional User"
    And I am logged in as "admin@intersect.org.au"
    And I have access groups
      | name    | users                     | id |
      | group-1 | external@intersect.org.au | 1  |
      | group-2 |                           | 2  |
    And I have data files
      | filename    | created_at       | uploaded_by            | start_time       | end_time            | path                | id | access  | access_to_all_institutional_users | access_to_user_groups | access_group_ids |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au  | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample1.txt | 1  | Private | true                              | true                  | 1                |
      | sample2.txt | 30/11/2011 10:15 | admin@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample2.txt | 2  | Private | true                              | true                  | 2                |
      | sample3.txt | 30/12/2011 12:34 | admin@intersect.org.au |                  |                     | samples/sample3.txt | 3  |         |                                   |                       |                  |
    And I am on the list data files page

  Scenario: Try to download without an API token
    When I make a request for the data download page for "sample1.txt" without an API token
    Then I should get a 401 response code

  Scenario: Try to download with an invalid API token
    When I make a request for the data download page for "sample1.txt" with an invalid API token
    Then I should get a 401 response code

  Scenario: Download a single file via API
    Given user "admin@intersect.org.au" has an API token
    When I make a request for the data download page for "sample1.txt" as "admin@intersect.org.au" with a valid API token
    Then I should get a 200 response code
    And I should get a file with name "sample1.txt" and content type "text/plain"
    And the file should contain "Plain text file sample1.txt"

  Scenario: Download a file as unauthorised access user via API
    Given I have a user "non-inst-user@intersect.org.au" with role "Non-Institutional User"
    And user "non-inst-user@intersect.org.au" has an API token
    When I make a request for the data download page for "sample1.txt" as "non-inst-user@intersect.org.au" with a valid API token
    Then I should get a 403 response code
    When I make a request for the data download page for "sample2.txt" as "non-inst-user@intersect.org.au" with a valid API token
    Then I should get a 403 response code
    When I make a request for the data download page for "sample3.txt" as "non-inst-user@intersect.org.au" with a valid API token
    Then I should get a 403 response code

  Scenario: Download a file of (default) Private Institutional access as an Institutional User via API
    Given user "researcher@intersect.org.au" has an API token
    When I make a request for the data download page for "sample1.txt" as "researcher@intersect.org.au" with a valid API token
    Then I should get a 200 response code
    And I should get a file with name "sample1.txt" and content type "text/plain"
    And the file should contain "Plain text file sample1.txt"

  Scenario: Download an access restricted file via API
    Given user "external@intersect.org.au" has an API token
    And user "researcher@intersect.org.au" has an API token
    When I make a request for the data download page for "sample1.txt" as "external@intersect.org.au" with a valid API token
    Then I should get a 200 response code
    And I should get a file with name "sample1.txt" and content type "text/plain"
    And the file should contain "Plain text file sample1.txt"
    When I make a request for the data download page for "sample2.txt" as "external@intersect.org.au" with a valid API token
    Then I should get a 403 response code
    When I make a request for the data download page for "sample3.txt" as "external@intersect.org.au" with a valid API token
    Then I should get a 403 response code

  Scenario: Download a selection of files from the cart
    When I add "sample1.txt" to the cart
    And I add "sample2.txt" to the cart
    And I click on "Download"
    Then I should get a file with name "sample1.txt.zip" and content type "application/zip"
    And I should receive a zip file matching "samples/zip"

  Scenario: Download a single file from the cart
    When I add "sample1.txt" to the cart
    And I click on "Download"
    Then I should get a file with name "sample1.txt" and content type "text/plain"
    And the file should contain "Plain text file sample1.txt"

  Scenario: Downloading regular file requires log in
    Given I follow "Sign out"
    And I am on the data file download page for sample1.txt
    And I should see "You need to log in before continuing."

  Scenario: Downloading unpublished package requires log in
    Given I have facility "ROS Weather Station" with code "ROS_WS"
    And I have experiments
      | name          | facility            |
      | My Experiment | ROS Weather Station |
    And I add "sample1.txt" to the cart
    And I add "sample2.txt" to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Filename" with "my_package"
    And I fill in "Title" with "Package Title"
    And I select "My Experiment" from "Experiment"
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I follow "Sign out"
    And I am on the data file download page for my_package.zip
    And I should see "You need to log in before continuing."

  Scenario: Downloading published package does not require log in
    Given I have facility "ROS Weather Station" with code "ROS_WS"
    And I have experiments
      | name          | facility            |
      | My Experiment | ROS Weather Station |
    And I add "sample1.txt" to the cart
    And I add "sample2.txt" to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Filename" with "my_package"
    And I fill in "Title" with "Package Title"
    And I select "My Experiment" from "Experiment"
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I follow "Publish"
    Then I should see "Package has been successfully submitted for publishing."
    And I follow "Sign out"
    And I am on the data file download page for my_package.zip
    Then I should get a file with name "my_package.zip" and content type "application/zip"
    And I should receive a zip file matching "my_package/zip"
