Feature: Perform listing facilities and their associated experiments via API
  As a researcher
  I want to get a list of all facilities and their experiments via API so I can see what parameters are available for searching

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Institutional User"
    And user "researcher@intersect.org.au" has an API token
    Given I have facilities
      | name      | code | id |
      | Facility0 | f1   | 1  |
      | Facility1 | f2   | 2  |
      | Facility2 | f3   | 3  |
    And I have experiments
      | name    | facility  | id |
      | F1_exp1 | Facility1 | 11 |
      | F0_exp2 | Facility0 | 12 |
      | F1_exp3 | Facility1 | 13 |

  Scenario: Try to get facility and experiment list without an API token
    When I get the facility and experiment list without an API token
    Then I should get a 401 response code

  Scenario: Try to search with an invalid API token
    When I get the facility and experiment list with an invalid API token
    Then I should get a 401 response code

  Scenario: Get facility and experiment list via API
    When I get the facility and experiment list as user "researcher@intersect.org.au"
    Then I should get a 200 response code
    And the JSON response should equal:
    """
    [
      { "facility_id": 1,
        "facility_name": "Facility0",
        "experiments": [ {"id": 12, "name": "F0_exp2"} ]
      },
      { "facility_id": 2,
        "facility_name": "Facility1",
        "experiments": [ {"id": 11, "name": "F1_exp1"}, {"id": 13, "name": "F1_exp3"} ]
      },
      { "facility_id": 3,
        "facility_name": "Facility2",
        "experiments": []
      }
    ]
    """


