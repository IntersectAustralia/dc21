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

  @javascript
  Scenario: Package is now available as a file type to search on
    Given I am on the list data files page
    And I follow Showing
    And I click on "Type:"
    Then I should see "PACKAGE"

  @javascript
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
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I should see "http://handle.westernsydney.edu.au:8081/1959.7/hiev_0"
    When I am on the create package page
    Then I should see "Filename"
    And I should see "Experiment"
    And I fill in "Title" with "Package 2"
    And I fill in "Filename" with "my_package2"
    And I select "My Experiment" from "Experiment"
    And I check "Video"
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I should see "http://handle.westernsydney.edu.au:8081/1959.7/hiev_1"

#EYETRACKER-140
  @javascript
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
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    # running in background
    And I press "Create Package"
    Then I should see "Package is now queued for processing in the background."
    And I should be on the data file details page for my_package1.zip
    And I should see "http://handle.westernsydney.edu.au:8081/1959.7/hiev_0"
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
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    # running in forergound
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I should be on the data file details page for my_package2.zip
    And I should see "http://handle.westernsydney.edu.au:8081/1959.7/hiev_1"
    And I should see details displayed
      | Parents  | sample1.txt\nsample2.txt   |
      | Children | No children files defined. |

  @javascript
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
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I should see "http://handle.westernsydney.edu.au:8081/1959.7/hiev_0"
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
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    And I should see "http://handle.westernsydney.edu.au:8081/1959.7/hiev_1"
    And I should not see "http://handle.westernsydney.edu.au:8081/1959.7/hiev_0"

  @javascript
  Scenario: Package filename should not allow illegal characters
    Given I am on the list data files page
    And I add sample1.txt to the cart
    And I add sample2.txt to the cart
    When I am on the create package page
    And I fill in "Filename" with "/ \ ? * : | < > "
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "cannot contain any of the following characters: / \ ? * : | < >"

  @javascript
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
    And I should see "Access rights type must be Open, Conditional or Restricted"

  @javascript
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
    And I select "Conditional" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
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
      | Access Rights Type   | Conditional                  |
      | Licence              | CC BY: Attribution           |

  @javascript
  Scenario: Back button - hardcode url
    When I am on the create package page
    And I follow "Back"
    Then I should be on the list data files page

  @javascript
  Scenario: Back button goes back in history
    Given I am on the list data files page
    And I add sample1.txt to the cart
    Given I am on the new experiment page for facility 'ROS Weather Station'
    And I press "Save Experiment"
    Then I should see "Start date can't be blank"
    And I follow "1 File in Cart"
    And I follow "Package"
    Then I should be on the create package page

  @javascript
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
  @javascript
  Scenario: Add a new label to package
    Given I am on the list data files page
    And I add sample1.txt to the cart
    When I am on the create package page
    And I fill in "package_label_list" with "bebb@|Abba|cuba|AA<script></script>"
    And I check select2 field "package_label_list" updated value to "Abba,bebb@,cuba,AA<script></script>"
    And I fill in "Filename" with "my_package1"
    And I select "My Experiment" from "Experiment"
    And I fill in "Title" with "Package 1"
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    When I should be on the data file details page for my_package1.zip
    Then I should see field "Labels" with value "AA<script></script>, Abba, bebb@, cuba"

  #EYETRACKER-88
  @javascript
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
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    When I should be on the data file details page for my_package1.zip
    Then I should see field "Labels" with value "test1, this3"

  @javascript
  Scenario: Create package specifying access rights type, grant numbers, related websites , creator and contributors
    Given I am on the list data files page
    And I add sample1.txt to the cart
    And I wait for 4 seconds
    When I am on the create package page
    And I wait for 4 seconds
    And "Fred Bloggs (admin@intersect.org.au)" should be selected for "Creator"
    And I fill in "package_grant_number_list" with "bebb@|Abba|cuba|AA<script></script>"
    And I check select2 field "package_grant_number_list" updated value to "Abba,bebb@,cuba,AA<script></script>"
    And I fill in "package_related_website_list" with "http://example.com | https://test.com| ftp://127.0.0.1/test"
    And I check select2 field "package_related_website_list" updated value to "ftp://127.0.0.1/test, http://example.com, https://test.com"
    And I fill in "package_contributor_list" with "cont3 | CONT@| AAdd<>"
    And I check select2 field "package_contributor_list" updated value to "AAdd<>, CONT@, cont3"
    And I select "Conditional" from "package_access_rights_type"
    And I select "CC BY: Attribution" from "Licence"
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
    Then I should see field "Related Websites" with value "ftp://127.0.0.1/test, http://example.com, https://test.com"
    Then file "my_package1.zip" should have contributors "AAdd<>,CONT@,cont3"
    Then I should see field "Access Rights Type" with value "Conditional"
    Then I should see field "Licence" with value "CC BY: Attribution"
    Then I should see field "Creator" with value "Fred Bloggs (admin@intersect.org.au)"


  @javascript
  Scenario: Cannot create package with invalid related websites
    Given I am on the list data files page
    And I add sample1.txt to the cart
    And I wait for 4 seconds
    When I am on the create package page
    And I fill in "package_related_website_list" with "webweb|test:123|http://sdjfklsdjfklsdjflksdjfklsdjflsdjfksdjflsdjflksdjklfjsdlkfjskdljflksdjfklsdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflksdjfklsdjflksdjfklsdjfkldsjfklsdjflksdjflksdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflkdsjflksdjfklsdjflksdjfklsdjfklsjfklsdjfklsdjfklsdjfklsdjfklsdjfklsdjflksdsdjfklsdjfklsdjflksdjfklsdjflsdjfksdjflsdjflksdjklfjsdlkfjskdljflksdjfklsdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflksdjfklsdjflksdjfklsdjfkldsjfklsdjflksdjflksdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflkdsjflksdjfklsdjflksdjfklsdjfklsjfklsdjfklsdjfklsdjfklsdjfklsdjfklsdjflksd.com"
    And I check select2 field "package_related_website_list" updated value to "webweb|test:123|http://sdjfklsdjfklsdjflksdjfklsdjflsdjfksdjflsdjflksdjklfjsdlkfjskdljflksdjfklsdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflksdjfklsdjflksdjfklsdjfkldsjfklsdjflksdjflksdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflkdsjflksdjfklsdjflksdjfklsdjfklsjfklsdjfklsdjfklsdjfklsdjfklsdjfklsdjflksdsdjfklsdjfklsdjflksdjfklsdjflsdjfksdjflsdjflksdjklfjsdlkfjskdljflksdjfklsdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflksdjfklsdjflksdjfklsdjfkldsjfklsdjflksdjflksdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflkdsjflksdjfklsdjflksdjfklsdjfklsjfklsdjfklsdjfklsdjfklsdjfklsdjfklsdjflksd.com"
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
    Then I should see "Please correct the following before continuing: Related websites url webweb is not a valid url Related websites url test:123 is not a valid url Related websites url is too long (maximum is 80 characters)"

  @javascript
  Scenario: Cannot create package that exceeds the maximum allowable size
    When I have the following system configuration
      | max_package_size | max_package_size_unit |
      | 1                | bytes                 |
    And I am on the list data files page
    And I add sample1.txt to the cart
    And I add sample2.txt to the cart
    When I am on the create package page
    Then I should see "Cannot create package. Total size of files in the cart exceeds the maximum package size."

  @javascript
  Scenario: License changes when the experiment changes
    Given I have experiments
      | name   | facility            | access_rights                                    |
      | Expr 1 | ROS Weather Station | http://creativecommons.org/licenses/by/4.0       |
      | Expr 2 | ROS Weather Station | http://creativecommons.org/licenses/by-sa/4.0    |
      | Expr 3 | Flux Tower          | http://creativecommons.org/licenses/by-nd/4.0    |
      | Expr 4 | Flux Tower          | http://creativecommons.org/licenses/by-nc/4.0    |
      | Expr 5 | Flux Tower          | http://creativecommons.org/licenses/by-nc-sa/4.0 |
    And I am on the list data files page
    And I add sample1.txt to the cart
    And I wait for 4 seconds
    When I am on the create package page
    And I select "Expr 1" from "Experiment"
    Then I should see "CC BY: Attribution" selected for "Licence"
    And I select "Expr 2" from "Experiment"
    Then I should see "CC BY-SA: Attribution-Share Alike" selected for "Licence"
    And I select "Expr 3" from "Experiment"
    Then I should see "CC BY-ND: Attribution-No Derivative Works" selected for "Licence"
    And I select "Expr 4" from "Experiment"
    Then I should see "CC BY-NC: Attribution-Noncommercial" selected for "Licence"
    And I select "Expr 5" from "Experiment"
    Then I should see "CC BY-NC-SA: Attribution-Noncommercial-Share Alike" selected for "Licence"

