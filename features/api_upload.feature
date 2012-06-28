Feature: Upload files via the API
  In order to streamline the data load process
  As a user
  I want to be able to have my PC automatically send files to DC21

  Background:
    Given I have a user "researcher@intersect.org.au" with role "Researcher"
    And user "researcher@intersect.org.au" has an API token
    And I have facility "Flux Tower" with code "FLUX"
    Given I have experiments
      | name              | facility            |
      | Flux Experiment 1 | Flux Tower          |
      | Flux Experiment 2 | Flux Tower          |
    And I have tags
      | name       |
      | Photo      |
      | Video      |
      | Gap-Filled |

  Scenario: Try to upload without an API token
    When I submit an API upload request without an API token
    Then I should get a 401 response code

