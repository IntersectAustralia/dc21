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
      | Gap-Filled |

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
    And I should get a JSON response with filename "weather_station_05_min.dat" and type "RAW" with no messages
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

  Scenario Outline: Invalid input scenarios
    When I submit an API upload request with the following parameters as user "researcher@intersect.org.au"
      | file       | <file>       |
      | type       | <type>       |
      | experiment | <experiment> |
    Then I should get a 400 response code
    And I should get a JSON response with errors "<errors>"
  Examples:
    | file                                                          | type      | experiment        | errors                                           | description                 |
    |                                                               | RAW       | Flux Experiment 1 | File is required                                 | missing file                |
    | samples/full_files/weather_station/weather_station_05_min.dat |           | Flux Experiment 1 | File type is required                            | missing type                |
    | samples/full_files/weather_station/weather_station_05_min.dat | PROCESSED |                   | Experiment id is required                        | missing experiment          |
    | samples/full_files/weather_station/weather_station_05_min.dat |           |                   | Experiment id is required, File type is required | missing experiment and type |
    | samples/full_files/weather_station/weather_station_05_min.dat | BLAH      | Flux Experiment 1 | File type not recognised                         | invalid type                |

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


