@javascript

Feature: Create a package
  In order to handle multiple data files which belong to a group
  As a user
  I want to bundle them into a package for upload/download

  Background:
    Given I am logged in as "admin@intersect.org.au"
    And I have facility "ROS Weather Station" with code "ROS_WS"
    And I have facility "Flux Tower" with code "FLUX"
    And I have data files
      | filename    | created_at       | uploaded_by            | start_time       | end_time            | path                | id |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au  | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample1.txt | 1  |
      | sample2.txt | 30/11/2011 10:15 | admin@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample2.txt | 2  |
      | sample3.txt | 30/12/2011 12:34 | admin@intersect.org.au |                  |                     | samples/sample3.txt | 3  |
    And I have experiments
      | name              | facility            |
      | My Experiment     | ROS Weather Station |
      | Rain Experiment   | ROS Weather Station |
      | Flux Experiment 1 | Flux Tower          |
      | Flux Experiment 2 | Flux Tower          |
      | Flux Experiment 3 | Flux Tower          |
    And I have tags
      | name       |
      | Photo      |
      | Video      |
      | Gap-Filled |
    Given I have languages
      | language_name | iso_code |
      | English       | en       |
      | Spanish       | es       |
    Given I have the following system configuration
      | language    | rights_statement | entity              | research_centre_name |
      | Spanish     | blah blah        | Intersect Australia | Intersect Research   |

  Scenario: Package is now available as a file type to search on
    Given I am on the list data files page
    And I follow Showing
    And I click on "Type:"
    Then I should see "PACKAGE"

  Scenario: New package auto generates external ID
    Given I am on the list data files page
    And I add sample1.txt to the cart
    And I add sample2.txt to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I should see select2 field "package_label_list" with value ""
    And I fill in "Title" with "Package 1"
    And I fill in "Filename" with "my_package1"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I should see "http://handle.uws.edu.au:8081/1959.7/hiev__0"
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Title" with "Package 2"
    And I fill in "Filename" with "my_package2"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I should see "http://handle.uws.edu.au:8081/1959.7/hiev__1"

#EYETRACKER-140
  Scenario: New package creates parent relationships
    Given I am on the list data files page
    And I add sample1.txt to the cart
    And I add sample2.txt to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I should see select2 field "package_label_list" with value ""
    And I fill in "Title" with "Package 1"
    And I fill in "Filename" with "my_package1"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    # running in background
    And I press "Create Package"
    Then I should see "Package is now queued for processing in the background."
    And I should be on the data file details page for my_package1.zip
    And I should see "http://handle.uws.edu.au:8081/1959.7/hiev__0"
    And I should see details displayed
      | Parents  | sample1.txt\nsample2.txt   |
      | Children | No children files defined. |
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Title" with "Package 2"
    And I fill in "Filename" with "my_package2"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    And I uncheck "Run in background?"
    # running in forergound
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I should be on the data file details page for my_package2.zip
    And I should see "http://handle.uws.edu.au:8081/1959.7/hiev__1"
    And I should see details displayed
      | Parents  | sample1.txt\nsample2.txt   |
      | Children | No children files defined. |

  Scenario: External ID is not reused
    Given I am on the list data files page
    And I add sample1.txt to the cart
    And I add sample2.txt to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Title" with "Package 1"
    And I fill in "Filename" with "my_package1"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I should see "http://handle.uws.edu.au:8081/1959.7/hiev__0"
    And I follow "Delete This File"
    And I confirm the popup
    And I should see "The file 'my_package1.zip' was successfully archived."
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Title" with "Package 2"
    And I fill in "Filename" with "my_package2"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I should see "http://handle.uws.edu.au:8081/1959.7/hiev__1"
    And I should not see "http://handle.uws.edu.au:8081/1959.7/hiev__0"

  Scenario: Package filename should not allow illegal characters
    Given I am on the list data files page
    And I add sample1.txt to the cart
    And I add sample2.txt to the cart
    When I am on the create package page
    And I fill in "Filename" with "/ \ ? * : | < > "
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "cannot contain any of the following characters: / \ ? * : | < >"

  Scenario: New package - empty form submission
    Given I am on the list data files page
    And I add sample3.txt to the cart
    And I add sample2.txt to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Filename can't be blank"
    And I should see "Experiment can't be blank"
    And I should see "Title can't be blank"

  Scenario: New package - rendering correct data_file view screen
    Given I am on the list data files page
    And I add sample1.txt to the cart
    And I add sample2.txt to the cart
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Filename" with "my_other_package"
    And I fill in "Description" with "Here's a description"
    And I fill in "Title" with "Test title"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    And I uncheck "Run in background?"
    And I press "Create Package"
    When I am on the data file details page for my_other_package.zip
    Then I should see details displayed
      | Name                 | my_other_package.zip         |
      | Type                 | PACKAGE                      |
      | File format          | BAGIT                        |
      | Description          | Here's a description         |
      | Experiment           | My Experiment                |
      | Title                | Test title                   |
      | Language             | Spanish                      |
      | Rights Statement     | blah blah                    |
      | HDL Handle           | hdl.handle.net/1959.7/hiev_0 |
      | Physical Location    | Intersect Australia          |
      | Research Centre Name | Intersect Research           |

  Scenario: Back button - hardcode url
    When I am on the create package page
    And I follow "Back"
    Then I should be on the list data files page

  Scenario: Back button goes back in history
    Given I am on the list data files page
    And I add sample1.txt to the cart
    Given I am on the new experiment page for facility 'ROS Weather Station'
    And I press "Save Experiment"
    Then I should see "Start date can't be blank"
    And I follow "1 File in Cart"
    And I follow "Package"
    Then I should be on the create package page

  Scenario: Back button resets link after erroneous package save
    Given I am on the list data files page
    And I add sample1.txt to the cart
    Given I am on the new experiment page for facility 'ROS Weather Station'
    And I press "Save Experiment"
    Then I should see "Start date can't be blank"
    And I follow "1 File in Cart"
    And I follow "Package"
    Then I should be on the create package page
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Filename can't be blank"
    And I follow "Back"
    Then I should be on the list data files page

  #EYETRACKER-88
  Scenario: Add a new label to package
    Given I am on the list data files page
    And I add sample1.txt to the cart
    When I am on the create package page
    And I fill in "package_label_list" with "bebb@|Abba|cuba|AA<script></script>"
    And I check select2 field "package_label_list" updated value to "Abba,bebb@,cuba,AA<script></script>"
    And I fill in "Filename" with "my_package1"
    And I select "My Experiment" from "Experiment"
    And I fill in "Title" with "Package 1"
    And I uncheck "Run in background?"
    And I press "Create Package"
    When I should be on the data file details page for my_package1.zip
    Then I should see field "Labels" with value "AA<script></script>, Abba, bebb@, cuba"

  #EYETRACKER-88
  Scenario: Delete an existing label when creating package
    Given I am on the list data files page
    And I add sample1.txt to the cart
    When I am on the create package page
    And I fill in "package_label_list" with "test1|that2|this3"
    And I check select2 field "package_label_list" updated value to "test1,that2,this3"
    And I fill in "package_label_list" with "this3|test1"
    And I check select2 field "package_label_list" updated value to "test1,this3"
    And I fill in "Filename" with "my_package1"
    And I select "My Experiment" from "Experiment"
    And I fill in "Title" with "Package 1"
    And I uncheck "Run in background?"
    And I press "Create Package"
    When I should be on the data file details page for my_package1.zip
    Then I should see field "Labels" with value "test1, this3"

  Scenario: Create package specifying access rights type, grant numbers and related websites
    Given I am on the list data files page
    And I add sample1.txt to the cart
    And I wait for 4 seconds
    When I am on the create package page
    And I fill in "package_grant_number_list" with "bebb@|Abba|cuba|AA<script></script>"
    And I check select2 field "package_grant_number_list" updated value to "Abba,bebb@,cuba,AA<script></script>"
    And I fill in "package_related_website_list" with "webweb|a_site|siteB|http://example.com"
    And I check select2 field "package_related_website_list" updated value to "webweb|a_site|siteB|http://example.com"
    And I select "Conditional" from "package_access_rights_type"
    And I should see "Spanish"
    And I should see "blah blah"
    And I should see "Intersect Australia"
    And I should see "Intersect Research"
    And I fill in "Filename" with "my_package1"
    And I select "My Experiment" from "Experiment"
    And I fill in "Title" with "Package 1"
    And I uncheck "Run in background?"
    And I press "Create Package"
    When I should be on the data file details page for my_package1.zip
    Then I should see field "Grant Numbers" with value "AA<script></script>, Abba, bebb@, cuba"
    Then I should see field "Related Websites" with value "a_site, http://example.com, siteB, webweb"
    Then I should see field "Access Rights Type" with value "Conditional"
