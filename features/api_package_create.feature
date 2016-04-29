
Feature: Create a package from the API
  In order to handle multiple data files which belong to a group
  As a user
  I want to bundle them into a package for upload/download

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Institutional User"
    And user "researcher@intersect.org.au" has an API token
    And I have facility "ROS Weather Station" with code "ROS_WS"
    And I have facility "Flux Tower" with code "FLUX"
    And I have data files
      | filename    | created_at       | uploaded_by            | start_time       | end_time            | path                | id |
      | sample1.txt | 01/12/2011 13:45 | sean@intersect.org.au  | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample1.txt | 1  |
      | sample2.txt | 30/11/2011 10:15 | admin@intersect.org.au | 1/6/2010 6:42:01 | 30/11/2011 18:05:23 | samples/sample2.txt | 2  |
      | sample3.txt | 30/12/2011 12:34 | admin@intersect.org.au |                  |                     | samples/sample3.txt | 3  |
    And I have data files
      | filename    | created_at       | uploaded_by            | start_time       | end_time            | path                   | file_processing_status| id |
      | error_file.txt | 30/12/2011 12:34 | admin@intersect.org.au |               |                     | samples/error_file.txt |               ERROR   | 4  |
    And I have data files
      | filename               | created_at       | uploaded_by            | start_time  | end_time | path                           | file_processing_status| transfer_status| id |
      | incomplete_package.zip | 30/12/2011 12:34 | admin@intersect.org.au |             |          | samples/incomplete_package.zip | PACKAGE               | FAILED         | 5  |
    And I have experiments
      | name              | facility            | id |
      | My Experiment     | ROS Weather Station | 1  |
      | Rain Experiment   | ROS Weather Station | 2  |
      | Flux Experiment 1 | Flux Tower          | 3  |
      | Flux Experiment 2 | Flux Tower          | 4  |
      | Flux Experiment 3 | Flux Tower          | 5  |
    And I have tags
      | name       |
      | Photo      |
      | Video      |
      | Gap-Filled |

  Scenario: Try to package without an API token
    When I perform an API package create without an API token
      | | |
    Then I should get a 401 response code

  Scenario: Try to package with an invalid API token
    When I perform an API package create with an invalid API token
      | | |
    Then I should get a 401 response code

  Scenario: Try to package with no arguments
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | | |
    Then I should get a 400 response code
    And I should get a JSON response with message "file_ids is required and must be an Array"

  Scenario: Try to package with invalid file id
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids | abc_123 |
    Then I should get a 400 response code
    And I should get a JSON response with message "file id 'abc_123' is not a valid file id"

  Scenario: Try to package with a file id that does not exist
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids | 1,2,3,8 |
    Then I should get a 400 response code
    And I should get a JSON response with message "file with id '8' could not be found"

  Scenario: Try to package without a filename, experiment or title
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids | 1,2,3 |
    Then I should get a 400 response code
    And I should get a JSON response with message "filename can't be blank"
    And I should get a JSON response with message "experiment can't be blank"
    And I should get a JSON response with message "title can't be blank"
    And I should get a JSON response with message "access_rights_type must be Open, Conditional or Restricted"

  Scenario: Try to package with an invalid experiment id
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1,2,3       |
      | filename           | my_pack.zip |
      | title              | My title    |
      | access_rights_type | Open        |
      | experiment_id      | 11          |
    Then I should get a 400 response code
    And I should get a JSON response with message "experiment can't be blank"

  Scenario: Try to package with error file
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 4                |
      | filename           | my_package       |
      | experiment_id      | 1                |
      | title              | my magic package |
      | access_rights_type | Open             |
    Then I should get a 400 response code
    And I should get a JSON response with message "file '4' is not in a state that can be packaged"

  Scenario: Try to package with error file and optional parameter
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids      | 4    |
      | filename      | my_package       |
      | experiment_id | 1                |
      | title         | my magic package |
      | force |  true   |
      | access_rights_type | Open             |
    Then I should get a 200 response code
    And I should get a JSON response with message "Warning: file '4' is in state 'ERROR'"
    And I should get a JSON response with package name "my_package.zip"
    And file "my_package.zip" should have experiment "My Experiment"
    And file "my_package.zip" should have title "my magic package"

  Scenario: Try to package with incomplete package
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids      | 5    |
      | filename      | my_package       |
      | experiment_id | 1                |
      | title         | my magic package |
      | access_rights_type | Open             |
    Then I should get a 400 response code
    And I should get a JSON response with message "file '5' is not in a state that can be packaged"

  Scenario: Try to package with incomplete package and optional parameter set to true
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids      | 5    |
      | filename      | my_package       |
      | experiment_id | 1                |
      | title         | my magic package |
      | force |  true  |
      | access_rights_type | Open             |
    Then I should get a 200 response code
    And I should get a JSON response with message "Warning: file '5' is in state 'FAILED'"
    And I should get a JSON response with package name "my_package.zip"
    And file "my_package.zip" should have experiment "My Experiment"
    And file "my_package.zip" should have title "my magic package"

  Scenario: Try to package with incomplete package and optional parameter set to false
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids      | 5    |
      | filename      | my_package       |
      | experiment_id | 1                |
      | title         | my magic package |
      | force |  false  |
      | access_rights_type | Open             |
    Then I should get a 400 response code
    And I should get a JSON response with message "file '5' is not in a state that can be packaged"

  Scenario: Try to package with invalid access rights type
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1                   |
      | access_rights_type | BadAccessRightsType |
    Then I should get a 400 response code
    And I should get a JSON response with message "access_rights_type is not included in the list"
    And I should get a JSON response with message "access_rights_type must be Open, Conditional or Restricted"

  Scenario: package is created successfully in the background
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1,2,3            |
      | filename           | my_package       |
      | experiment_id      | 1                |
      | title              | my magic package |
      | access_rights_type | Open             |
    Then I should get a 200 response code
    And I should get a JSON response with message "Package is now queued for processing in the background."
    And I should get a JSON response with package name "my_package.zip"
    And file "my_package.zip" should have experiment "My Experiment"
    And file "my_package.zip" should have title "my magic package"
    And file "my_package.zip" should have transfer status "QUEUED"
    And file "my_package.zip" should have access rights type "Open"

  Scenario: package is created successfully in the foreground
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1,2,3            |
      | filename           | my_package       |
      | experiment_id      | 1                |
      | title              | my magic package |
      | run_in_background  | false            |
      | access_rights_type | Open             |
    Then I should get a 200 response code
    And I should get a JSON response with message "Package was successfully created."
    And I should get a JSON response with package name "my_package.zip"
    And file "my_package.zip" should have experiment "My Experiment"
    And file "my_package.zip" should have title "my magic package"
    And file "my_package.zip" should have transfer status "COMPLETE"
    And file "my_package.zip" should have access rights type "Open"

  Scenario: package is created successfully with all the options
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1,2,3                     |
      | filename           | my_package                |
      | experiment_id      | 1                         |
      | title              | my magic package          |
      | run_in_background  | false                     |
      | description        | some friendly description |
      | tag_names          | "Photo","Video"           |
      | label_names        | "Label1","Label2"         |
      | start_time         | 2011-10-10 01:01:01       |
      | end_time           | 2011-11-11 02:02:02       |
      | run_in_background  | false                     |
      | access_rights_type | Restricted                |
    Then I should get a 200 response code
    And I should get a JSON response with message "Package was successfully created."
    And I should get a JSON response with package name "my_package.zip"
    And file "my_package.zip" should have experiment "My Experiment"
    And file "my_package.zip" should have title "my magic package"
    And file "my_package.zip" should have transfer status "COMPLETE"
    And file "my_package.zip" should have description "some friendly description"
    And file "my_package.zip" should have label "Label1"
    And file "my_package.zip" should have label "Label2"
    And file "my_package.zip" should have tag "Photo"
    And file "my_package.zip" should have tag "Video"
    And file "my_package.zip" should have start time "2011-10-10 01:01:01"
    And file "my_package.zip" should have end time "2011-11-11 02:02:02"
    And file "my_package.zip" should have access rights type "Restricted"

  Scenario: Package is created with grant numbers
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1,2,3                     |
      | filename           | my_package                |
      | experiment_id      | 1                         |
      | title              | my magic package          |
      | description        | some friendly description |
      | access_rights_type | Restricted                |
      | run_in_background  | false                     |
      | grant_numbers      | "GRANT-1","GRANT-2"       |
    Then I should get a 200 response code
    And I should get a JSON response with message "Package was successfully created."
    And I should get a JSON response with package name "my_package.zip"
    And file "my_package.zip" should have experiment "My Experiment"
    And file "my_package.zip" should have title "my magic package"
    And file "my_package.zip" should have transfer status "COMPLETE"
    And file "my_package.zip" should have description "some friendly description"
    And file "my_package.zip" should have grant number "GRANT-1"
    And file "my_package.zip" should have grant number "GRANT-2"

  Scenario: Package is created with related websites
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1,2,3                         |
      | filename           | my_package                    |
      | experiment_id      | 1                             |
      | title              | my magic package              |
      | description        | some friendly description     |
      | access_rights_type | Restricted                    |
      | run_in_background  | false                         |
      | related_websites   | "http://website1.com","http://website2.com" |
    Then I should get a 200 response code
    And I should get a JSON response with message "Package was successfully created."
    And I should get a JSON response with package name "my_package.zip"
    And file "my_package.zip" should have experiment "My Experiment"
    And file "my_package.zip" should have title "my magic package"
    And file "my_package.zip" should have transfer status "COMPLETE"
    And file "my_package.zip" should have description "some friendly description"
    And file "my_package.zip" should have related website "http://website1.com"
    And file "my_package.zip" should have related website "http://website2.com"
    And file "my_package.zip" should have license "http://creativecommons.org/licenses/by/4.0"

  Scenario: Package is created with contributors
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1,2,3                     |
      | filename           | my_package                |
      | experiment_id      | 1                         |
      | title              | my magic package          |
      | description        | some friendly description |
      | access_rights_type | Restricted                |
      | run_in_background  | false                     |
      | contributor_names     | CONT-1 , CONT-2       |
    Then I should get a 200 response code
    And I should get a JSON response with message "Package was successfully created."
    And I should get a JSON response with package name "my_package.zip"
    And file "my_package.zip" should have experiment "My Experiment"
    And file "my_package.zip" should have title "my magic package"
    And file "my_package.zip" should have transfer status "COMPLETE"
    And file "my_package.zip" should have description "some friendly description"
    And file "my_package.zip" should have contributor "CONT-1"
    And file "my_package.zip" should have contributor "CONT-2"
    And file "my_package.zip" should have creator "Admin User (tao@intersect.org.au)"

  Scenario: Package is created with creator
    Given I have a user "tao@intersect.org.au" with role "Admin User"
    And user "tao@intersect.org.au" has an API token
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1,2,3                     |
      | filename           | my_package                |
      | experiment_id      | 1                         |
      | title              | my magic package          |
      | description        | some friendly description |
      | access_rights_type | Restricted                |
      | run_in_background  | false                     |
      | creator_email      | tao@intersect.org.au      |
    Then I should get a 200 response code
    And I should get a JSON response with message "Package was successfully created."
    And I should get a JSON response with package name "my_package.zip"
    And file "my_package.zip" should have experiment "My Experiment"
    And file "my_package.zip" should have title "my magic package"
    And file "my_package.zip" should have transfer status "COMPLETE"
    And file "my_package.zip" should have description "some friendly description"
    And file "my_package.zip" should have creator "Admin User (tao@intersect.org.au)"

  Scenario: Package can be created with a specified license
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1,2,3                         |
      | filename           | my_package                    |
      | experiment_id      | 1                             |
      | title              | my magic package              |
      | description        | some friendly description     |
      | access_rights_type | Restricted                    |
      | run_in_background  | false                         |
      | license            | CC-BY-NC-SA                   |
    Then I should get a 200 response code
    And I should get a JSON response with message "Package was successfully created."
    And I should get a JSON response with package name "my_package.zip"
    And file "my_package.zip" should have experiment "My Experiment"
    And file "my_package.zip" should have title "my magic package"
    And file "my_package.zip" should have transfer status "COMPLETE"
    And file "my_package.zip" should have description "some friendly description"
    And file "my_package.zip" should have license "http://creativecommons.org/licenses/by-nc-sa/4.0"

  Scenario: Package cannot be created if it exceeds the system configured maximum package size
    When I have the following system configuration
      | max_package_size | max_package_size_unit |
      | 1                | bytes                 |
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1,2,3            |
      | filename           | my_package       |
      | experiment_id      | 1                |
      | title              | my magic package |
      | access_rights_type | Open             |
    Then I should get a 400 response code
    And I should get a JSON response with message "total size of files exceeds the maximum package size"

  Scenario: Package cannot be created with invalid related websites
    When I perform an API package create with the following parameters as user "researcher@intersect.org.au"
      | file_ids           | 1,2,3                         |
      | filename           | my_package                    |
      | experiment_id      | 1                             |
      | title              | my magic package              |
      | description        | some friendly description     |
      | access_rights_type | Restricted                    |
      | run_in_background  | false                         |
      | related_websites   | "test:123","website2.com","http://sdjfklsdjfklsdjflksdjfklsdjflsdjfksdjflsdjflksdjklfjsdlkfjskdljflksdjfklsdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflksdjfklsdjflksdjfklsdjfkldsjfklsdjflksdjflksdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflkdsjflksdjfklsdjflksdjfklsdjfklsjfklsdjfklsdjfklsdjfklsdjfklsdjfklsdjflksdsdjfklsdjfklsdjflksdjfklsdjflsdjfksdjflsdjflksdjklfjsdlkfjskdljflksdjfklsdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflksdjfklsdjflksdjfklsdjfkldsjfklsdjflksdjflksdjfklsdjfklsdjfklsdjflksdjflksdjfklsdjflksdjfklsdjflkdsjflksdjfklsdjflksdjfklsdjfklsjfklsdjfklsdjfklsdjfklsdjfklsdjfklsdjflksd.com" |
    Then I should get a 400 response code
    And I should get a JSON response with message "related_websites.url test:123 is not a valid url"
    And I should get a JSON response with message "related_websites.url website2.com is not a valid url"
    And I should get a JSON response with message "related_websites.url is too long (maximum is 80 characters)"

