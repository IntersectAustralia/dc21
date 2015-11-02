@javascript
Feature: Publish a PACKAGE
  In order to tell ANDS about my data
  As a user
  I want to publish a PACKAGE

  Background:
    Given I have the usual roles
    And I have languages
      | language_name | iso_code |
      | English       | en       |
      | Spanish       | es       |
    And I have the following system configuration
      | language    | rights_statement | entity              | research_centre_name | registry_object_group           |
      | English     | blah blah        | Intersect Australia | Intersect Research   | Intersect Registry Object Group |
    And I have a user "admin@intersect.org.au" with role "Administrator"
    And I have a user "publisher@intersect.org.au" with role "Administrator"
    And I have a user "researcher@intersect.org.au" with role "Researcher"
    And I am logged in as "admin@intersect.org.au"
    And I have facilities
      | name                | code   | primary_contact             |
      | ROS Weather Station | ROS_WS | researcher@intersect.org.au |
      | Flux Tower          | FLUX   | researcher@intersect.org.au |
    And I have data files
      | filename      | file_processing_status | created_at       | uploaded_by                 | start_time       | end_time            | path                  | published | published_date      | published_by               | transfer_status | access_rights_type |
      | package1.zip  | PACKAGE                | 01/12/2011 13:45 | researcher@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/package1.zip  | false     |                     |                            | COMPLETE        |  Open              |
      | package2.zip  | PACKAGE                | 30/11/2011 10:15 | admin@intersect.org.au      | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/package2.zip  | false     |                     |                            | COMPLETE        | Restricted         |
      | published.zip | PACKAGE                | 30/12/2011 12:34 | admin@intersect.org.au      |                  |                     | samples/published.zip | true      | 27/12/2012 13:05:23 | publisher@intersect.org.au | COMPLETE        | Conditional        |
      | sample1.txt   | PROCESSED              | 01/12/2011 13:45 | researcher@intersect.org.au |                  |                     | samples/sample1.txt   | false     |                     |                            | COMPLETE        |                    |
      | sample2.txt   | RAW                    | 01/12/2011 13:45 | researcher@intersect.org.au | 25/9/2011        | 3/11/2011           | samples/sample2.txt   | false     |                     |                            | COMPLETE        |                    |
    And I have experiments
      | name                | facility            | subject  | access_rights                                    |
      | My Experiment       | ROS Weather Station | Rainfall | http://creativecommons.org/licenses/by-nc-nd/4.0 |
      | Reserved Experiment | ROS Weather Station | Wind     | N/A                                              |
      | Rain Experiment     | ROS Weather Station | Rainfall | http://creativecommons.org/licenses/by-nc-sa/4.0 |
      | Flux Experiment 1   | Flux Tower          | Rainfall | http://creativecommons.org/licenses/by-nc/4.0    |
      | Flux Experiment 2   | Flux Tower          | Rainfall | http://creativecommons.org/licenses/by-nc/4.0    |
      | Flux Experiment 3   | Flux Tower          | Rainfall | http://creativecommons.org/licenses/by-nc/4.0    |
    And I have tags
      | name       |
      | Photo      |
      | Video      |
      | Gap-Filled |

  Scenario: Search by date range then publish - zip should include full files (regardless of whether they fall outside date range)
    Given I do a date search for data files with dates "2011-10-10" and "2011-10-15"
    And I follow "Add All"
    And I confirm the popup
    When I am on the create package page
    And I fill in "Title" with "My Package Title"
    And I fill in "Filename" with "My Collection Of Stuff"
    And I select "Rain Experiment" from "Experiment"
    And I fill in "Description" with "Describe my collection of stuff"
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    When I follow "Publish"
    And I confirm the popup
    Then I should see "Package has been successfully submitted for publishing."
    And the RIF-CS file for the latest published collection should match "samples/rif-cs/range_oct_10_oct_15.xml"
#    When I perform a GET for the zip file for the latest published collection I should get a zip matching "samples/published_zips/range_oct_10_oct_15"


  Scenario: Search by something other than date then publish - zip should include full files
    Given I am on the list data files page
    And I click on "Showing all 5 files"
    And I click on "Type:"
    And I check "RAW"
    And I press "Update Search Results"
    And I follow "Add All"
    And I confirm the popup
    When I am on the create package page
    And I fill in "Title" with "My Package Title"
    And I fill in "Filename" with "Raw Stuff"
    And I select "Reserved Experiment" from "Experiment"
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    When I follow "Publish"
    And I confirm the popup
    Then I should see "Package has been successfully submitted for publishing."
    And the RIF-CS file for the latest published collection should match "samples/rif-cs/type_raw_search.xml"
#    When I perform a GET for the zip file for the latest published collection I should get a zip matching "samples/published_zips/type_raw"


  Scenario: None of the files have dates - RIFCS should not include temporal coverage
    Given I am on the list data files page
    And I click on "Showing all 5 files"
    And I click on "Filename:"
    And I fill in "Filename" with "sample1"
    And I press "Update Search Results"
    And I follow "Add All"
    And I confirm the popup
    When I am on the create package page
    And I fill in "Title" with "My Package Title"
    And I fill in "Filename" with "No Dates"
    And I select "My Experiment" from "Experiment"
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    When I follow "Publish"
    And I confirm the popup
    Then I should see "Package has been successfully submitted for publishing."
    And the RIF-CS file for the latest published collection should match "samples/rif-cs/sample1-rif-cs.xml"


  Scenario: Metadata should reflect publish status for a package
    Given I am on the data file details page for package1.zip
    Then I should see details displayed
      | Name      | package1.zip |
      | Published | No           |
    And I should not see "Published date:"
    When I am on the data file details page for published.zip
    Then I should see details displayed
      | Name           | published.zip    |
      | Published      | Yes              |
      | Published by   | Fred Bloggs      |
      | Published date | 2012-12-27 13:05 |
    When I am on the data file details page for sample1.txt
    Then I should not see "Published:"
    And I should not see "Published date:"

  Scenario: Publish button should only appear for packages
    Given I am on the list data files page
    And I add sample1.txt to the cart
    When I am on the create package page
    And I fill in "Title" with "Package Title"
    And I fill in "Filename" with "my_package"
    And I select "My Experiment" from "Experiment"
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    When I am on the data file details page for sample1.txt
    Then I should not see "Publish"
    When I am on the data file details page for my_package.zip
    Then I should see "Publish"

  Scenario: Researchers should be able to delete their own packages if they're not published
    Given I logout
    And I am logged in as "researcher@intersect.org.au"
    When I am on the data file details page for package1.zip
    And I click on "Delete This File"
    Then I confirm the popup
    And I wait for the page
    And I should see "The file 'package1.zip' was successfully archived."

  Scenario: Researchers should not be able to delete their own packages if they're published

    When I am on the data file details page for package1.zip
    And I follow "Publish"
    Then I confirm the popup
    And I should see "Package has been successfully submitted for publishing."
    Given I logout
    And I am logged in as "researcher@intersect.org.au"
    When I am on the data file details page for package1.zip
    And I should not see "Delete This File"
    Given I logout
    And I am logged in as "admin@intersect.org.au"
    When I am on the data file details page for package1.zip
    And I click on "Delete This File"
    Then I confirm the popup
    And I wait for the page
    And I should see "The file 'package1.zip' was successfully archived."

  Scenario: Only administrators are allowed to edit a package once published
    Given I logout
    And I am logged in as "researcher@intersect.org.au"
    And I am on the data file details page for published.zip
    Then I should not see "Edit Metadata"
    Then I logout
    When I am logged in as "admin@intersect.org.au"
    And I am on the data file details page for published.zip
    Then I should see "Edit Metadata"

 #UWSHIEVMOD-87: update title value in rif-cs
  Scenario: Relate webiste title should be set correctly in rif-cs
    Given I am on the list data files page
    And I click on "Showing all 5 files"
    And I click on "Type:"
    And I check "RAW"
    And I press "Update Search Results"
    And I follow "Add All"
    And I confirm the popup
    When I am on the create package page
    And I fill in "Title" with "My Package Title"
    And I fill in "Filename" with "Raw Stuff"
    And I select "Reserved Experiment" from "Experiment"
    And I select "Open" from "Access Rights Type"
    And I select "CC BY: Attribution" from "Licence"
    And I fill in "package_related_website_list" with "http://example.com| http://www.google.com | http://www.facebook.com"
    And I check select2 field "package_related_website_list" updated value to "http://example.com, http://www.facebook.com, http://www.google.com "
    And I expect uri-open of "http://example.com" to return "<html><title>Example</title></html>"
    And I expect uri-open of "http://www.google.com" to return "<html><title>Google</title></html>"
    And I expect uri-open of "http://www.facebook.com" to return "<html><title>Facebook</title></html>"
    And I uncheck "Run in background?"
    And I press "Create Package"
    Then I should see "Package was successfully created."
    When I follow "Publish"
    And I confirm the popup
    Then I should see "Package has been successfully submitted for publishing."
    And the RIF-CS file for the latest published collection should match "samples/rif-cs/related_websites.xml"
  
#    When I perform a GET for the zip file for the latest published collection I should get a zip matching "samples/published_zips/type_raw"

#
#  Scenario: Publish button does not show prior to searching
#    Given I am on the list data files page
#    Then I should not see link "Publish"
#
#  @javascript
#  Scenario: Try to publish without entering a name
#    Given I do a date search for data files with dates "2011-10-10" and "2011-10-15"
#    When I follow "Publish"
#    Then I should be on the publish page
#    When I press "Confirm"
#    And I should see "Name can't be blank"
#    And there should be no published collections
#
#  @javascript
#  Scenario: Try to publish with a duplicate name
#    Given I have a published collection called "my collection"
#    And I do a date search for data files with dates "2011-10-10" and "2011-10-15"
#    When I follow "Publish"
#    And I fill in "Name" with "my collection"
#    And I press "Confirm"
#    Then I should see "Name has already been taken"
#
#  @javascript
#  Scenario: RIF-CS and zip file are snapshots at the point in time where the collection was published
#    # publish
#    Given I do a date search for data files with dates "2011-10-10" and "2011-10-15"
#    And I publish these search results as "My Collection Of Stuff" with description "Describe my collection of stuff"
#    # change some details
#    When I edit data file "weather_station_05_min.dat"
#    And I fill in "Name" with "changedit.dat"
#    And I press "Update"
#    # published collection should remain as before
#    Then there should be a published collection record named "My Collection Of Stuff" with creator "admin@intersect.org.au"
#    And the RIF-CS file for the latest published collection should match "samples/rif-cs/range_oct_10_oct_15.xml"
#    When I perform a GET for the zip file for the latest published collection I should get a zip matching "samples/published_zips/range_oct_10_oct_15"


