Feature: Upload files via the API
  In order to streamline the data load process
  As a user
  I want to be able to have my PC automatically send files to DC21

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Institutional User"
    And I have a user "researcher2@intersect.org.au" with role "Institutional User"
    And user "researcher@intersect.org.au" has an API token
    And user "researcher2@intersect.org.au" has an API token
    And I have facility "Flux Tower" with code "FLUX"
    Given I have experiments
      | name              | facility   |
      | Flux Experiment 1 | Flux Tower |
      | Flux Experiment 2 | Flux Tower |
    And I have tags
      | name       |
      | Photo      |
      | Video      |
      | Gap Filled |
    And I have access groups
      | name    |
      | group-A |
      | group-B |
      | group-C |
      | group-D |

  Scenario: Try to upload without an API token
    When I submit an API upload request without an API token
    Then I should get a 401 response code

  Scenario: Try to upload with an invalid API token
    When I submit an API upload request with an invalid API token
    Then I should get a 401 response code

  Scenario: Successful upload TOA5 file with minimum required metadata
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | experiment | Flux Experiment 1                                             |
    Then I should get a 200 response code
    And I should get a JSON response with filename "weather_station_05_min.dat" and type "RAW" with the success message
    And file "weather_station_05_min.dat" should have experiment "Flux Experiment 1"
    And file "weather_station_05_min.dat" should have type "RAW"
    And file "weather_station_05_min.dat" should have automatically extracted metadata
    And file "weather_station_05_min.dat" should have access level "Private"
    And file "weather_station_05_min.dat" should be set as private access to all institutional users
    And file "weather_station_05_min.dat" should not be set as private access to user groups

  # EYETRACKER-106
  Scenario: Successful upload TOA5 file with minimum required metadata with Org Level 2 identifier
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | org_level2 | Flux Experiment 1                                             |
    Then I should get a 200 response code
    And I should get a JSON response with filename "weather_station_05_min.dat" and type "RAW" with the success message
    And file "weather_station_05_min.dat" should have experiment "Flux Experiment 1"
    And file "weather_station_05_min.dat" should have type "RAW"
    And file "weather_station_05_min.dat" should have automatically extracted metadata

  # EYETRACKER-106
  Scenario: Org level 2 identifier takes precedence
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | org_level2 | Flux Experiment 2                                             |
      | experiment | Flux Experiment 1                                             |
    Then I should get a 200 response code
    And I should get a JSON response with filename "weather_station_05_min.dat" and type "RAW" with the success message
    And file "weather_station_05_min.dat" should have experiment "Flux Experiment 2"
    And file "weather_station_05_min.dat" should have type "RAW"
    And file "weather_station_05_min.dat" should have automatically extracted metadata

  Scenario: Optional description can be supplied on upload
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file        | samples/full_files/weather_station/weather_station_05_min.dat |
      | type        | RAW                                                           |
      | experiment  | Flux Experiment 1                                             |
      | description | My description                                                |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should have description "My description"

  Scenario: Optional tags can be supplied on upload
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | experiment | Flux Experiment 1                                             |
      | tag_names  | "Photo","Gap Filled"                                          |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should have tags "Photo,Gap Filled"

  Scenario: Tags containing commas work ok
    Given I have tag "Contains, a comma"
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | experiment | Flux Experiment 1                                             |
      | tag_names  | "Photo","Contains, a comma"                                   |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should have 2 tags

  Scenario: Single tag is accepted
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | experiment | Flux Experiment 1                                             |
      | tag_names  | "Photo"                                                       |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should have tags "Photo"

  Scenario: Optional start and end times are accepted
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/zip/sample1.txt          |
      | type       | RAW                              |
      | experiment | Flux Experiment 1                |
      | start_time | 2015-08-03 15:30:00              |
      | end_time   | 2015-08-04 15:30:00              |
    Then I should get a 200 response code
    And file "sample1.txt" should have start time "2015-08-03 15:30:00"
    And file "sample1.txt" should have end time "2015-08-04 15:30:00"
    And I should get a JSON response with message "File uploaded successfully."

  Scenario: Optional start and end times are accepted without the need for trailing zeros
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/zip/sample1.txt          |
      | type       | RAW                              |
      | experiment | Flux Experiment 1                |
      | start_time | 2015-08-03 5:30:00              |
      | end_time   | 2015-08-04 5:30:00              |
    Then I should get a 200 response code
    And file "sample1.txt" should have start time "2015-08-03 5:30:00"
    And file "sample1.txt" should have end time "2015-08-04 5:30:00"
    And I should get a JSON response without message "Supplied start_time and end_time have been ignored in favor of the uploaded file's metadata"
    And I should get a JSON response with message "File uploaded successfully."

  Scenario: Optional start and end times are ignored when uploading a TOA5 file
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | experiment | Flux Experiment 1                                             |
      | tag_names  | "Photo"                                                       |
      | start_time | 2015-08-03 15:30:00                                           |
      | end_time   | 2015-08-04 15:30:00                                           |
    Then I should get a 200 response code
    And I should get a JSON response with message "Supplied start_time and end_time have been ignored in favor of the uploaded file's metadata"
    And I should get a JSON response with message "File uploaded successfully."
    And file "weather_station_05_min.dat" should not have start time "2015-08-03 15:30:00"
    And file "weather_station_05_min.dat" should not have end time "2015-08-04 15:30:00"

  Scenario Outline: Invalid input scenarios
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | <file>       |
      | type       | <type>       |
      | experiment | <experiment> |
      | tag_names  | <tag_names>  |
    Then I should get a 400 response code
    And I should get a JSON response with errors "<errors>"
  Examples:
    | file                                                          | type      | experiment        | errors                                                                     | tag_names      | description                 |
    |                                                               | RAW       | Flux Experiment 1 | File is required                                                           |                | missing file                |
    | samples/full_files/weather_station/weather_station_05_min.dat |           | Flux Experiment 1 | File type is required                                                      |                | missing type                |
    | samples/full_files/weather_station/weather_station_05_min.dat | PROCESSED |                   | Experiment id is required                                                  |                | missing experiment          |
    | samples/full_files/weather_station/weather_station_05_min.dat |           |                   | Experiment id is required, File type is required                           |                | missing experiment and type |
    | samples/full_files/weather_station/weather_station_05_min.dat | BLAH      | Flux Experiment 1 | File type not recognised                                                   |                | invalid type                |
    | samples/full_files/weather_station/weather_station_05_min.dat | RAW       | Flux Experiment 1 | Unknown tag 'Blah'                                                         | "Video","Blah" | unknown tag                 |
    | samples/full_files/weather_station/weather_station_05_min.dat | RAW       | Flux Experiment 1 | Incorrect format for tags - tags must be double-quoted and comma separated | "Video,"Blah"  | badly formatted tags        |

#EYETRACKER-95 EYETRACKER-106

  Scenario Outline: Invalid input scenarios for Org_level2
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | <file>       |
      | type       | <type>       |
      | org_level2 | <org_level2> |
      | tag_names  | <tag_names>  |
    Then I should get a 400 response code
    And I should get a JSON response with errors "<errors>"
  Examples:
    | file                                                          | type      | org_level2        | errors                                                                     | tag_names      | description                 |
    |                                                               | RAW       | Flux Experiment 1 | File is required                                                           |                | missing file                |
    | samples/full_files/weather_station/weather_station_05_min.dat |           | Flux Experiment 1 | File type is required                                                      |                | missing type                |
    | samples/full_files/weather_station/weather_station_05_min.dat | PROCESSED |                   | Experiment id is required                                                  |                | missing experiment          |
    | samples/full_files/weather_station/weather_station_05_min.dat |           |                   | Experiment id is required, File type is required                           |                | missing experiment and type |
    | samples/full_files/weather_station/weather_station_05_min.dat | BLAH      | Flux Experiment 1 | File type not recognised                                                   |                | invalid type                |
    | samples/full_files/weather_station/weather_station_05_min.dat | RAW       | Flux Experiment 1 | Unknown tag 'Blah'                                                         | "Video","Blah" | unknown tag                 |
    | samples/full_files/weather_station/weather_station_05_min.dat | RAW       | Flux Experiment 1 | Incorrect format for tags - tags must be double-quoted and comma separated | "Video,"Blah"  | badly formatted tags        |

  Scenario: Invalid input - experiment id not found
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file          | samples/full_files/weather_station/weather_station_05_min.dat |
      | type          | RAW                                                           |
      | experiment_id | 999999999                                                     |
    Then I should get a 400 response code
    And I should get a JSON response with errors "Supplied org level 2 id does not exist"

  Scenario: Invalid input - org level 2 id not found
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file          | samples/full_files/weather_station/weather_station_05_min.dat |
      | type          | RAW                                                           |
      | org_level2_id | 999999999                                                     |
    Then I should get a 400 response code
    And I should get a JSON response with errors "Supplied org level 2 id does not exist"

  Scenario: Invalid input - file parameter is not a valid file
    When I submit an API upload request with an invalid file as user "researcher@intersect.org.au"
    Then I should get a 400 response code
    And I should get a JSON response with errors "Supplied file was not a valid file"

  Scenario Outline: Warning outcomes
    Given I have uploaded "subsetted/range_oct_10_oct_12/weather_station_15_min.dat" with type "RAW"
    And I have uploaded "sample1.txt" with type "RAW"
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | <file path>       |
      | type       | <type>            |
      | experiment | Flux Experiment 1 |
    Then I should get a 200 response code
    And I should get a JSON response with filename "<resulting name>" and type "<resulting type>" with messages "<messages>"
    And file "<resulting name>" should have type "<resulting type>"
    And file "<resulting name>" should have experiment "Flux Experiment 1"
    And there should be <resulting file count> files in the system

  Examples:
    | type      | messages                                    | resulting name                            | resulting type | resulting file count | description                                         | file path                                                                                |
    | RAW       | success                                     | weather_station_15_min_oct_13_15.dat      | RAW            | 3                    | no overlap, different file name                     | samples/subsetted/range_oct_13_oct_15_renamed/weather_station_15_min_oct_13_15.dat       |
    | RAW       | renamed                                     | weather_station_15_min_1.dat              | RAW            | 3                    | no overlap, clashing file name                      | samples/subsetted/range_oct_13_oct_15/weather_station_15_min.dat                         |
    | RAW       | goodoverlap, ownership_inherited            | weather_station_15_min_oct_10_onwards.dat | RAW            | 2                    | safe overlap, different file name                   | samples/subsetted/range_oct_10_onwards_renamed/weather_station_15_min_oct_10_onwards.dat |
    | RAW       | goodoverlap, ownership_inherited            | weather_station_15_min.dat                | RAW            | 2                    | safe overlap, replacing file of same name           | samples/subsetted/range_oct_10_onwards/weather_station_15_min.dat                        |
    | RAW       | goodoverlap, renamed, ownership_inherited   | sample1_1.txt                             | RAW            | 2                    | safe overlap, clashing file name                    | samples/subsetted/range_oct_10_onwards_renamed/sample1.txt                               |
    | RAW       | badoverlap                                  | weather_station_15_min_oct_11_13.dat      | ERROR          | 3                    | bad overlap, different file name                    | samples/subsetted/range_oct_11_oct_13/weather_station_15_min_oct_11_13.dat               |
    | RAW       | renamed, badoverlap                         | weather_station_15_min_1.dat              | ERROR          | 3                    | bad overlap, clashing file name                     | samples/subsetted/range_oct_11_oct_13/weather_station_15_min.dat                         |
    | RAW       | success                                     | sample2.txt                               | RAW            | 3                    | non-TOA5, different file name                       | samples/sample2.txt                                                                      |
    | RAW       | renamed                                     | sample1_1.txt                             | RAW            | 3                    | non-TOA5, clashing file name                        | samples/sample1.txt                                                                      |
    | PROCESSED | success                                     | weather_station_15_min_oct_10_onwards.dat | PROCESSED      | 3                    | safe overlap, but not marked raw                    | samples/subsetted/range_oct_10_onwards_renamed/weather_station_15_min_oct_10_onwards.dat |
    | PROCESSED | renamed                                     | weather_station_15_min_1.dat              | PROCESSED      | 3                    | safe overlap, but not marked raw, clashing filename | samples/subsetted/range_oct_10_onwards/weather_station_15_min.dat                        |

  #EYETRACKER-88
  Scenario: Add a list of labels to files uploaded through the API
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | experiment | Flux Experiment 1                                             |
      | labels     | "Label1","Label_2","label 3"                                  |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should have 3 labels
    And file "weather_station_05_min.dat" should have labels "Label1|Label_2|label 3"

  Scenario: Add a list of contributors to files uploaded through the API
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | experiment | Flux Experiment 1                                             |
      | contributors     | CONT1,CONT2,CONT 3                                  |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should have 3 contributors
    And file "weather_station_05_min.dat" should have contributors "CONT 3,CONT1,CONT2"
    And file "weather_station_05_min.dat" should have creator "Institutional User (researcher@intersect.org.au)"

  Scenario: Add a creator to files uploaded through the API
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | experiment | Flux Experiment 1                                             |
      | creator_email     | researcher2@intersect.org.au                                  |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should have creator "Institutional User (researcher2@intersect.org.au)"

  #EYETRACKER-88
  Scenario: Labels containing commas work ok
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | experiment | Flux Experiment 1                                             |
      | labels     | "Photo","Contains, a comma"                                   |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should have 2 labels
    And file "weather_station_05_min.dat" should have labels "Contains, a comma|Photo"

  #EYETRACKER-172
  Scenario: Assign valid parent relationships on API file upload
    Given I have uploaded "full_files/weather_station/weather_station_15_min.dat" with type "RAW"
    And I have uploaded "sample1.txt" with type "PROCESSED"
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file             | samples/full_files/weather_station/weather_station_05_min.dat |
      | type             | RAW                                                           |
      | experiment       | Flux Experiment 1                                             |
      | parent_filenames | weather_station_15_min.dat,sample1.txt                        |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should have 2 parents
    And file "weather_station_05_min.dat" should have parents "weather_station_15_min.dat,sample1.txt"
    And file "sample1.txt" should have 1 children files
    And file "sample1.txt" should have children "weather_station_05_min.dat"
    And file "weather_station_15_min.dat" should have 1 children
    And file "weather_station_15_min.dat" should have children "weather_station_05_min.dat"

  #EYETRACKER-172
  Scenario: Assign parent relationships on non-existing files on API file upload
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file             | samples/full_files/weather_station/weather_station_05_min.dat |
      | type             | RAW                                                           |
      | experiment       | Flux Experiment 1                                             |
      | parent_filenames | weather_station_15_min.dat,sample1.txt                        |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should have 0 parents
    And file "weather_station_05_min.dat" should have parents ""

  Scenario: Ownership and Access Controls are inherited when uploading subsets of existing data
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | samples/full_files/weather_station/weather_station_05_min.dat |
      | type       | RAW                                                           |
      | experiment | Flux Experiment 1                                             |
      | access     | Public                                                        |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should be created by "researcher@intersect.org.au"
    And file "weather_station_05_min.dat" should have access level "Public"
    And file "weather_station_05_min.dat" should not be set as private access to all institutional users
    And file "weather_station_05_min.dat" should not be set as private access to user groups
    When I submit an API upload request with the following parameters as user "researcher2@intersect.org.au"
      | file                              | samples/full_files/weather_station/weather_station_05_min.dat |
      | type                              | RAW                                                           |
      | experiment                        | Flux Experiment 1                                             |
      | access                            | Private                                                       |
      | access_to_all_institutional_users | false                                                         |
    Then I should get a 200 response code
    And I should get a JSON response with message "The file has inherited ownership and access control metadata from weather_station_05_min.dat"
    And file "weather_station_05_min.dat" should be created by "researcher@intersect.org.au"
    And file "weather_station_05_min.dat" should have access level "Public"
    And file "weather_station_05_min.dat" should not be set as private access to all institutional users
    And file "weather_station_05_min.dat" should not be set as private access to user groups
    And file "weather_station_05_min.dat" should have access groups ""
    When I submit an API upload request with the following parameters as user "researcher2@intersect.org.au"
      | file                  | samples/full_files/weather_station/weather_station_05_min.dat |
      | type                  | RAW                                                           |
      | experiment            | Flux Experiment 1                                             |
      | access                | Private                                                       |
      | access_to_user_groups | true                                                          |
      | access_groups         | group-C,group-A,group-B                                       |
    Then I should get a 200 response code
    And I should get a JSON response with message "The file has inherited ownership and access control metadata from weather_station_05_min.dat"
    And file "weather_station_05_min.dat" should be created by "researcher@intersect.org.au"
    And file "weather_station_05_min.dat" should have access level "Public"
    And file "weather_station_05_min.dat" should not be set as private access to all institutional users
    And file "weather_station_05_min.dat" should not be set as private access to user groups
    And file "weather_station_05_min.dat" should have access groups ""

  Scenario Outline: Supplying multiple access control keywords in API upload should upload file and set it to the most restricted access setting (from what's specified)
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file                              | samples/full_files/weather_station/weather_station_05_min.dat |
      | type                              | PROCESSED                                                     |
      | experiment                        | Flux Experiment 1                                             |
      | access                            | <access>                                                      |
      | access_to_all_institutional_users | <all_inst_users>                                    |
      | access_to_user_groups             | <user_groups>                                       |
      | access_groups                     | <group_names>                                                 |
    Then I should get a 200 response code
    And file "weather_station_05_min.dat" should have access level "<resulting_access>"
    And file "weather_station_05_min.dat" should have the private access options: "<resulting_inst>" to all institutional users, "<resulting_groups>" to user groups
    And file "weather_station_05_min.dat" should have access groups "<resulting_group_names>"
  Examples:
      | access  | all_inst_users | user_groups | group_names     | resulting_access | resulting_inst | resulting_groups | resulting_group_names |
      | Public  | true           |             |                 | Private          | true           | false            |                       |
      | Public  |                | true        |                 | Private          | false          | true             |                       |
      | Public  |                |             | group-A,group-B | Private          | false          | true             | group-A,group-B       |
      | Public  | true           | true        |                 | Private          | true           | true             |                       |
      | Public  |                |             | made,up,groups  | Private          | false          | true             |                       |
      | Public  | true           |             | group-C,other   | Private          | true           | true             | group-C               |
      |         | true           |             |                 | Private          | true           | false            |                       |
      |         |                | true        |                 | Private          | false          | true             |                       |
      |         |                |             | group-A,group-B | Private          | false          | true             | group-A,group-B       |
      |         | true           | true        |                 | Private          | true           | true             |                       |
      |         |                |             | made,up,groups  | Private          | false          | true             |                       |
      |         | true           |             | group-C,other   | Private          | true           | true             | group-C               |

  Scenario Outline: Invalid access control parameters in the API upload should result in error
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file                              | samples/full_files/weather_station/weather_station_05_min.dat |
      | type                              | RAW                                                           |
      | experiment                        | Flux Experiment 1                                             |
      | access                            | <access>                    |
      | access_to_all_institutional_users | <access_to_all_inst_users>  |
      | access_to_user_groups             | <access_to_user_groups>     |
    Then I should get a 400 response code
    And I should get a JSON response with errors "<errors>"
  Examples:
    | access  | access_to_all_inst_users | access_to_user_groups | errors |
    | bad     |                          |                       | Supplied access was not valid: has to be either Public or Private  |
    | Public  | blah                     |                       | Supplied access_to_all_institutional_users was not valid: has to be either true or false |
    | Private |                          | meh                   | Supplied access_to_user_groups was not valid: has to be either true or false             |
    | some    | random                   | stuff                 | Supplied access was not valid: has to be either Public or Private, Supplied access_to_all_institutional_users was not valid: has to be either true or false, Supplied access_to_user_groups was not valid: has to be either true or false |
    | other   | thing                    |                       | Supplied access was not valid: has to be either Public or Private, Supplied access_to_all_institutional_users was not valid: has to be either true or false |
    | made    |                          | up                    | Supplied access was not valid: has to be either Public or Private, Supplied access_to_user_groups was not valid: has to be either true or false |
    |         | random                   | stuff                 | Supplied access_to_all_institutional_users was not valid: has to be either true or false, Supplied access_to_user_groups was not valid: has to be either true or false |

  Scenario Outline: Specifying one or more non-existing access groups in API upload parameters should upload file with warning
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file                              | samples/full_files/weather_station/weather_station_05_min.dat |
      | type                              | RAW                                                           |
      | experiment                        | Flux Experiment 1                                             |
      | access                            | Private                                                       |
      | access_to_all_institutional_users | false                                                         |
      | access_to_user_groups             | true                                                          |
      | access_groups                     | <group_names>                                                 |
    Then I should get a 200 response code
    And I should get a JSON response with filename "weather_station_05_min.dat" and type "RAW" with messages "<messages>"
    And file "weather_station_05_min.dat" should have access level "Private"
    And file "weather_station_05_min.dat" should be set as private access to user groups
    And file "weather_station_05_min.dat" should have access groups "<resulting_groups>"
    And file "weather_station_05_min.dat" should not be set as private access to all institutional users
    Examples:
      | group_names                   | messages                                                                 | resulting_groups |
      | other                         | File uploaded successfully., 1 access group does not exist in the system |                  |
      | group-A,avengers              | File uploaded successfully., 1 access group does not exist in the system | group-A          |
      | group-C,citrus,cake           | File uploaded successfully., 2 access groups do not exist in the system  | group-C          |
      | group-B,banana,group-C        | File uploaded successfully., 1 access group does not exist in the system | group-B,group-C  |
      | a,bunch,of,made,up,groups     | File uploaded successfully., 6 access groups do not exist in the system  |                  |
      | some,imaginary,groups,group-A | File uploaded successfully., 3 access groups do not exist in the system  | group-A          |