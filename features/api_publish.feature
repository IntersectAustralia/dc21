Feature: Publish a PACKAGE from the API
  In order to tell ANDS about my data
  As a user
  I want to publish a PACKAGE from the API

  Background:
    Given I have the usual roles
    And I have a user "admin@intersect.org.au" with role "Administrator"
    And I have a user "publisher@intersect.org.au" with role "Administrator"
    And I have a user "researcher@intersect.org.au" with role "Researcher"
    And user "admin@intersect.org.au" has an API token
    And user "publisher@intersect.org.au" has an API token
    And user "researcher@intersect.org.au" has an API token
    And I have facilities
      | name                | code   | primary_contact             |
      | ROS Weather Station | ROS_WS | researcher@intersect.org.au |
      | Flux Tower          | FLUX   | researcher@intersect.org.au |
    And I have data files
      | filename      | file_processing_status | created_at       | uploaded_by                 | start_time       | end_time            | path                  | id | published | published_date      | published_by               | transfer_status |
      | package1.zip  | PACKAGE                | 01/12/2011 13:45 | researcher@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/package1.zip  | 1  | false     |                     |                            | COMPLETE        |
      | package2.zip  | PACKAGE                | 30/11/2011 10:15 | admin@intersect.org.au      | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/package2.zip  | 2  | false     |                     |                            | COMPLETE        |
      | published.zip | PACKAGE                | 30/12/2011 12:34 | admin@intersect.org.au      |                  |                     | samples/published.zip | 3  | true      | 27/12/2012 13:05:23 | publisher@intersect.org.au | COMPLETE        |
      | sample1.txt   | PROCESSED              | 01/12/2011 13:45 | researcher@intersect.org.au |                  |                     | samples/sample1.txt   | 4  | false     |                     |                            | COMPLETE        |
      | sample2.txt   | RAW                    | 01/12/2011 13:45 | researcher@intersect.org.au | 25/9/2011        | 3/11/2011           | samples/sample2.txt   | 5  | false     |                     |                            | COMPLETE        |
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

  Scenario: Try to publish without an API token
    When I perform an API publish without an API token
      | | |
    Then I should get a 401 response code

  Scenario: Try to publish with an invalid API token
    When I perform an API publish with an invalid API token
      | | |
    Then I should get a 401 response code

  Scenario: Try to publish with no arguments
    When I perform an API publish with the following parameters as user "admin@intersect.org.au"
      | | |
    Then I should get a 400 response code
    And I should get a JSON response with message "package_id is required"

  Scenario: Try to publish with an invalid package_id
    When I perform an API publish with the following parameters as user "admin@intersect.org.au"
      | package_id | x |
    Then I should get a 400 response code
    And I should get a JSON response with message "Package with id x could not be found"

  Scenario: Try to publish with an unknown package_id
    When I perform an API publish with the following parameters as user "admin@intersect.org.au"
      | package_id | 10 |
    Then I should get a 400 response code
    And I should get a JSON response with message "Package with id 10 could not be found"

  Scenario: Try to publish with a package_id that is a data_file
    When I perform an API publish with the following parameters as user "admin@intersect.org.au"
      | package_id | 5 |
    Then I should get a 400 response code
    And I should get a JSON response with message "Package with id 5 could not be found"

  Scenario: Try to publish with a valid package_id
    When I perform an API publish with the following parameters as user "admin@intersect.org.au"
      | package_id | 1 |
    Then I should get a 200 response code
    And I should get a JSON response with message "Package has been successfully submitted for publishing."

  Scenario: Try to publish with a package that has already been published
    When I perform an API publish with the following parameters as user "admin@intersect.org.au"
      | package_id | 3 |
    Then I should get a 200 response code
    And I should get a JSON response with message "Package 3 is already submitted for publishing."

  Scenario: Try to publish as a non administrative user
    When I perform an API publish with the following parameters as user "researcher@intersect.org.au"
      | package_id | 3 |
    Then I should get a 401 response code
    And I should get a JSON response with message "Unauthorized"