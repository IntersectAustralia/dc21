Feature: Perform updates to data files and packages via API
  As a researcher
  I want to perform a updated to data files and packages via the API.

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
      | id | name                | facility            | subject  | access_rights                                    |
      | 1  | My Experiment       | ROS Weather Station | Rainfall | http://creativecommons.org/licenses/by-nc-nd/4.0 |
      | 2  | Reserved Experiment | ROS Weather Station | Wind     | N/A                                              |
      | 3  | Rain Experiment     | ROS Weather Station | Rainfall | http://creativecommons.org/licenses/by-nc-sa/4.0 |
      | 4  | Flux Experiment 1   | Flux Tower          | Rainfall | http://creativecommons.org/licenses/by-nc/4.0    |
      | 5  | Flux Experiment 2   | Flux Tower          | Rainfall | http://creativecommons.org/licenses/by-nc/4.0    |
      | 6  | Flux Experiment 3   | Flux Tower          | Rainfall | http://creativecommons.org/licenses/by-nc/4.0    |
    And I have tags
      | name       |
      | Photo      |
      | Video      |
      | Gap-Filled |
    And I have access groups
      | name    |
      | group-A |
      | group-B |
      | group-C |
      | group-D |

  Scenario: Try to update without an API token
    When I perform an API update without an API token
      | | |
    Then I should get a 401 response code

  Scenario: Try to update with an invalid API token
    When I perform an API update with an invalid API token
      | | |
    Then I should get a 401 response code

  Scenario: Try to update with no arguments
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | | |
    Then I should get a 400 response code
    And I should get a JSON response with message "file_id is required"

  Scenario: Try to update with an invalid file_id
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id | x |
    Then I should get a 400 response code
    And I should get a JSON response with message "file with id 'x' could not be found"

  Scenario: Try to update with an unknown file_id
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id | 100 |
    Then I should get a 400 response code
    And I should get a JSON response with message "file with id '100' could not be found"

  Scenario: Try to update without providing anything to update
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id | 5 |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"

  Scenario: Try to update the name of the data file
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id | 5            |
      | name    | new_name.txt |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "new_name.txt" has the following metadata
      | name | new_name.txt |

  Scenario: Try to update the experiment of the data file
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id          | 5 |
      | experiment_id    | 6 |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "sample2.txt" has the following metadata
      | experiment_id | 6 |

  Scenario: Try to update the description of the data file
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id          | 5                      |
      | description      | a nice new description |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "sample2.txt" has the following metadata
      | description | a nice new description |

  Scenario: Try to update the tags of the data file
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id          | 5                      |
      | tag_names        | Photo,Video,Gap-Filled |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "sample2.txt" should have tag "Photo"
    And file "sample2.txt" should have tag "Video"
    And file "sample2.txt" should have tag "Gap-Filled"

  Scenario: Try to update the parents of the data file
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id          | 5                        |
      | parent_filenames | sample1.txt,package1.zip |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "sample2.txt" should have parents "sample1.txt,package1.zip"

  Scenario: Try to update the labels of the data file
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id          | 5                        |
      | label_names      | new_label1,new_label2    |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "sample2.txt" should have label "new_label1"
    And file "sample2.txt" should have label "new_label2"

  Scenario: Try to update the creator of the data file
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id          | 5                        |
      | creator_email      | researcher@intersect.org.au    |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "sample2.txt" should have creator "Researcher (researcher@intersect.org.au)"

  Scenario: Try to update the contributors of a data file
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id               | 5                                                    |
      | contributor_names         | contributor_1,contributor_2                        |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "sample2.txt" should have contributor "contributor_1"
    And file "sample2.txt" should have contributor "contributor_2"

  Scenario: Try to update the access to Private of the data file
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id          | 5                        |
      | access           | Private                  |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "sample2.txt" should have access level "Private"

  Scenario: Try to update the access to Public of the data file
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id                           | 5                        |
      | access                            | Public                   |
      | access_to_all_institutional_users | false                    |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "sample2.txt" should have access level "Public"
    And file "sample2.txt" should not be set as private access to all institutional users

  Scenario: Try to update the access groups of the data file
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id                           | 5                        |
      | access                            | Private                  |
      | access_to_all_institutional_users | false                    |
      | access_to_user_groups             | true                     |
      | access_groups                     | group-C,group-A,group-B  |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "sample2.txt" should not be set as private access to all institutional users
    And file "sample2.txt" should be set as private access to user groups
    And file "sample2.txt" should have access groups "group-C,group-A,group-B"

  Scenario: Try to update a file with start time and end time
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id    | 5                                |
      | start_time | 2015-08-03 15:30:00              |
      | end_time   | 2015-08-04 15:30:00              |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And file "sample2.txt" should have start time "2015-08-03 15:30:00"
    And file "sample2.txt" should have end time "2015-08-04 15:30:00"

  Scenario: Try to update the access rights type of a package
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id              | 2                                |
      | access_rights_type   | Restricted                       |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And I should get a JSON response with warning "Updating a package will not cause rif-cs to be regenerated"
    And file "package2.zip" should have access rights type "Restricted"

  Scenario: Try to update the license of a package
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id              | 2                                |
      | license              | CC-BY-NC                         |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And I should get a JSON response with warning "Updating a package will not cause rif-cs to be regenerated"
    And file "package2.zip" should have license "http://creativecommons.org/licenses/by-nc/4.0"

  Scenario: Try to update the related websites of a package
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id              | 2                                                                            |
      | related_websites     | http://www.intersect.org.au,http://www.google.com.au                         |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And I should get a JSON response with warning "Updating a package will not cause rif-cs to be regenerated"
    And file "package2.zip" should have related website "http://www.google.com.au"
    And file "package2.zip" should have related website "http://www.intersect.org.au"

  Scenario: Try to update the grant numbers of a package
    When I perform an API update with the following parameters as user "admin@intersect.org.au"
      | file_id               | 2                                                    |
      | grant_numbers         | grant_number_1,grant_number_2                        |
    Then I should get a 200 response code
    And I should get a JSON response with message "Data file successfully updated"
    And I should get a JSON response with warning "Updating a package will not cause rif-cs to be regenerated"
    And file "package2.zip" should have grant number "grant_number_1"
    And file "package2.zip" should have grant number "grant_number_2"

