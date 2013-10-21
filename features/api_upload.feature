Feature: Upload files via the API
  In order to streamline the data load process
  As a user
  I want to be able to have my PC automatically send files to DC21

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And user "researcher@intersect.org.au" has an API token
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

  Scenario: Try to upload without an API token
    When I submit an API upload request without an API token
    Then I should get a 401 response code

  Scenario: Try to upload with in invalid API token
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
    | samples/full_files/weather_station/weather_station_05_min.dat | RAW       | Flux Experiment 1 | Unknown tag 'Blah'                                                             | "Video","Blah" | unknown tag                 |
    | samples/full_files/weather_station/weather_station_05_min.dat | RAW       | Flux Experiment 1 | Incorrect format for tags - tags must be double-quoted and comma separated | "Video,"Blah"  | badly formatted tags        |

  Scenario: Invalid input - experiment id not found
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file          | samples/full_files/weather_station/weather_station_05_min.dat |
      | type          | RAW                                                           |
      | experiment_id | 999999999                                                     |
    Then I should get a 400 response code
    And I should get a JSON response with errors "Supplied experiment id does not exist"

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
    | type      | messages             | resulting name                            | resulting type | resulting file count | description                                         | file path                                                                                |
    | RAW       | success              | weather_station_15_min_oct_13_15.dat      | RAW            | 3                    | no overlap, different file name                     | samples/subsetted/range_oct_13_oct_15_renamed/weather_station_15_min_oct_13_15.dat       |
    | RAW       | renamed              | weather_station_15_min_1.dat              | RAW            | 3                    | no overlap, clashing file name                      | samples/subsetted/range_oct_13_oct_15/weather_station_15_min.dat                         |
    | RAW       | goodoverlap          | weather_station_15_min_oct_10_onwards.dat | RAW            | 2                    | safe overlap, different file name                   | samples/subsetted/range_oct_10_onwards_renamed/weather_station_15_min_oct_10_onwards.dat |
    | RAW       | goodoverlap          | weather_station_15_min.dat                | RAW            | 2                    | safe overlap, replacing file of same name           | samples/subsetted/range_oct_10_onwards/weather_station_15_min.dat                        |
    | RAW       | goodoverlap, renamed | sample1_1.txt                             | RAW            | 2                    | safe overlap, clashing file name                    | samples/subsetted/range_oct_10_onwards_renamed/sample1.txt                               |
    | RAW       | badoverlap           | weather_station_15_min_oct_11_13.dat      | ERROR          | 3                    | bad overlap, different file name                    | samples/subsetted/range_oct_11_oct_13/weather_station_15_min_oct_11_13.dat               |
    | RAW       | renamed, badoverlap  | weather_station_15_min_1.dat              | ERROR          | 3                    | bad overlap, clashing file name                     | samples/subsetted/range_oct_11_oct_13/weather_station_15_min.dat                         |
    | RAW       | success              | sample2.txt                               | RAW            | 3                    | non-TOA5, different file name                       | samples/sample2.txt                                                                      |
    | RAW       | renamed              | sample1_1.txt                             | RAW            | 3                    | non-TOA5, clashing file name                        | samples/sample1.txt                                                                      |
    | PROCESSED | success              | weather_station_15_min_oct_10_onwards.dat | PROCESSED      | 3                    | safe overlap, but not marked raw                    | samples/subsetted/range_oct_10_onwards_renamed/weather_station_15_min_oct_10_onwards.dat |
    | PROCESSED | renamed              | weather_station_15_min_1.dat              | PROCESSED      | 3                    | safe overlap, but not marked raw, clashing filename | samples/subsetted/range_oct_10_onwards/weather_station_15_min.dat                        |


  Scenario Outline: Invalid input scenarios
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
    | samples/full_files/weather_station/weather_station_05_min.dat | RAW       | Flux Experiment 1 | Unknown tag 'Blah'                                                             | "Video","Blah" | unknown tag                 |
    | samples/full_files/weather_station/weather_station_05_min.dat | RAW       | Flux Experiment 1 | Incorrect format for tags - tags must be double-quoted and comma separated | "Video,"Blah"  | badly formatted tags        |
